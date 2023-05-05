import Flutter
import UIKit
import AuthenticationServices

@available(iOS 15.0, *)
public class FlutterPasskeyPlugin: NSObject, FlutterPlugin {
    class AuthCtrlDelegate: NSObject, ASAuthorizationControllerDelegate {
        private let semaphore = DispatchSemaphore(value: 0)
        private var result: (controller: ASAuthorizationController, authorization: ASAuthorization?, error: Error?)?

        func getResult() throws -> (controller: ASAuthorizationController, authorization: ASAuthorization?, error: Error?) {
            semaphore.wait()
            guard let ret = result else {
                throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1000, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
            }
            return ret
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            result = (controller, authorization, nil)
            semaphore.signal()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            result = (controller, nil, error)
            semaphore.signal()
        }
    }

    private func getPlatformVersion() -> String {
        return "iOS " + UIDevice.current.systemVersion
    }

    private func requestCredential(_ options: String) throws -> String {
        let jsonObj = try getJsonObject(options: options)
        let challenge = try getChallenge(jsonObj: jsonObj)
        let rpId = try getRpId(jsonObj: jsonObj)
        let (platformKeyRequest, platformKeyRequest2) = try createCredentialRegistrationRequests(jsonObj: jsonObj, rpId: rpId, challenge: challenge)
        let topController = try getTopController()
        let contextProvider = try getContextProvider(topController: topController)
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest, platformKeyRequest2])
        let authCtrlDelete = AuthCtrlDelegate()
        authController.delegate = authCtrlDelete
        authController.presentationContextProvider = contextProvider
        authController.performRequests()
        let result = try authCtrlDelete.getResult()
        return try processResult(result: result)
    }

    private func requestAssertion(_ options: String) throws -> String {
        let jsonObj = try getJsonObject(options: options)
        let (keyRequest, deviceRequest) = try createCredentialAssertionRequests(jsonObj: jsonObj)
        let authController = ASAuthorizationController(authorizationRequests: [ keyRequest,deviceRequest ] )
        let topController = try getTopController()
        let contextProvider = try getContextProvider(topController: topController)
        let authCtrlDelete = AuthCtrlDelegate()
        authController.delegate = authCtrlDelete
        authController.presentationContextProvider = contextProvider
        authController.performRequests()
        let result = try authCtrlDelete.getResult()
        return try processResult(result: result)
    }

    private func getJsonObject(options: String) throws -> [String: Any] {
        guard let jsonObj = options.jsonObject else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1002, userInfo: [NSLocalizedDescriptionKey: "Options not found"])
        }
        return jsonObj
    }

    private func getChallenge(jsonObj: [String: Any]) throws -> Data {
        guard let challengeStr = jsonObj["challenge"] as? String, let challenge = challengeStr.base64urlDecoded else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1005, userInfo: [NSLocalizedDescriptionKey: "Challenge not found"])
        }
        return challenge
    }

    private func getRpId(jsonObj: [String: Any]) throws -> String {
        var rpId = ""
        if let rpObj = jsonObj["rp"] as? [String: Any], let id = rpObj["id"] as? String { rpId = id }
        if let id = jsonObj["rpId"] as? String { rpId = id }
        if rpId.isEmpty {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1003, userInfo: [NSLocalizedDescriptionKey: "RP id not found"])
        }
        return rpId
    }

    private func getAllowedCredentials(jsonObj: [String: Any]) -> [[UInt8]]? {
        guard let allowedCredentialsArray = jsonObj["allowed_credentials"] as? [[String: Any]] else {
            return nil
        }

        var allowedCredentials: [[UInt8]] = []

        for credential in allowedCredentialsArray {
            if let id = credential["id"] as? String, let credentialID = id.base64urlDecoded {
                allowedCredentials.append(Array(credentialID))
            }
        }

        return allowedCredentials
    }

    private func createCredentialRegistrationRequests(jsonObj: [String: Any], rpId: String, challenge: Data) throws -> (ASAuthorizationRequest, ASAuthorizationRequest) {
        let (userName, userId) = try getUserInfo(jsonObj: jsonObj)
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let platformProvider2 = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        return (platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: userName, userID: userId),
                platformProvider2.createCredentialRegistrationRequest(challenge: challenge, displayName: userName, name: userName, userID: userId))
    }

    private func createCredentialAssertionRequests(jsonObj: [String: Any]) throws -> (ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest, ASAuthorizationPlatformPublicKeyCredentialAssertionRequest) {
        let challenge = try getChallenge(jsonObj: jsonObj)
        let rpId = try getRpId(jsonObj: jsonObj)
        let allowedCredentialsArray = getAllowedCredentials(jsonObj:jsonObj)!
        // Create Security Key request
        var credentialsArray: [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor] = []
        for credID in allowedCredentialsArray {
            credentialsArray.append(ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(credentialID: Data(credID),transports: [.nfc,.usb,.bluetooth]))
        }
        let securityKeyCredentialProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let keyRequest = securityKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
        keyRequest.allowedCredentials = credentialsArray
        // Create Devices request
        var deviceCredentialsArray: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = []
        for credID in allowedCredentialsArray {
            deviceCredentialsArray.append(ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: Data(credID)))
        }
        let platformKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let deviceRequest = platformKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
        deviceRequest.allowedCredentials = deviceCredentialsArray
        return (keyRequest, deviceRequest)
    }

    private func getUserInfo(jsonObj: [String: Any]) throws -> (String, Data) {
        guard let userObj = jsonObj["user"] as? [String: Any], let id = userObj["id"] as? String, let userName = userObj["name"] as? String, let userId = id.data(using: .utf8) else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1004, userInfo: [NSLocalizedDescriptionKey: "User id or name not found"])
        }
        return (userName, userId)
    }

    private func getTopController() throws -> UIViewController {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        guard var topController = keyWindow?.rootViewController else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1006, userInfo: [NSLocalizedDescriptionKey: "Root view controller not found"])
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        if let nav = topController as? UINavigationController {
            topController = nav.visibleViewController ?? topController
        }
        return topController
    }

    private func getContextProvider(topController: UIViewController) throws -> ASAuthorizationControllerPresentationContextProviding {
        guard let contextProvider = topController as? ASAuthorizationControllerPresentationContextProviding else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1007, userInfo: [NSLocalizedDescriptionKey: "Presentation context provider not found"])
        }
        return contextProvider
    }

    private func processResult(result: (controller: ASAuthorizationController, authorization: ASAuthorization?, error: Error?)) throws -> String {
        if let error = result.error {
            throw error
        }
        guard let authorization = result.authorization else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1008, userInfo: [NSLocalizedDescriptionKey: "Credential not found"])
        }
        return try processAuthorization(authorization: authorization)
    }

    private func processAuthorization(authorization: ASAuthorization) throws -> String {
           var response: [String: Any] = [:]

           if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
               response = processCredential(credential)
           } else if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialAssertion {
               response = processCredential(credential)
           } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
               response = processCredential(credential)
           } else {
               throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1009, userInfo: [NSLocalizedDescriptionKey: "Unknown credential type"])
           }

        return try convertResponseToJson(response: response)
    }

private func processCredential(_ credential: AnyObject) -> [String: Any] {
    var response: [String: Any] = [
        "id": credential.credentialID.base64url,
        "rawId": credential.credentialID.base64url,
        "type": "public-key",
        "response": [:],
        "clientExtensionResults": [:]
    ]

    if let credential = credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
        response["response"] = [
            "attestationObject": credential.rawAttestationObject?.base64url ?? "null",
            "clientDataJSON": credential.rawClientDataJSON.base64url,
            "getAuthenticatorData": [:],
            "getPublicKey": [:],
            "getPublicKeyAlgorithm": [:],
            "getTransports": [:],
        ]
    } else {
        response["response"] = [
            "authenticatorData": credential.rawAuthenticatorData.base64url,
            "signature": credential.signature.base64url,
            "clientDataJSON": credential.rawClientDataJSON.base64url,
        ]
    }

    return response
}

    private func convertResponseToJson(response: [String: Any]) throws -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: response), let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1010, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        return jsonString
    }

    private func createCredential(_ options: String, _ callback: @escaping (_ credential: String?, _ error: Error?) -> Void) {
        Task {
            do {
                let credential = try requestCredential(options)
                callback(credential, nil)
            } catch {
                callback(nil, error)
            }
        }
    }

    private func getCredential(_ options: String, _ callback: @escaping (_ credential: String?, _ error: Error?) -> Void) {
        Task {
            do {
                let credential = try requestAssertion(options)
                callback(credential, nil)
            } catch {
                callback(nil, error)
            }
        }
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_passkey", binaryMessenger: registrar.messenger())
        let instance = FlutterPasskeyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result(getPlatformVersion())
        case "createCredential":
            if let args = call.arguments as? Dictionary<String, Any>, let options = args["options"] as? String {
                createCredential(options) { credential, error in
                    if let err = error {
                        result(FlutterError(code: "\((err as NSError).code)", message: err.localizedDescription, details: nil))
                        return
                    }
                    result(credential!)
                }
            }
            else {
                result(FlutterError(code: "\(0x1001)", message: "Options not found", details: nil))
            }
        case "getCredential":
            if let args = call.arguments as? Dictionary<String, Any>, let options = args["options"] as? String {
                getCredential(options) { credential, error in
                    if let err = error {
                        result(FlutterError(code: "\((err as NSError).code)", message: err.localizedDescription, details: nil))
                        return
                    }
                    result(credential!)
                }
            }
            else {
                result(FlutterError(code: "\(0x1001)", message: "Options not found", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FlutterViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension String {
    var jsonObject: [String: Any]? {
        guard let data = self.data(using: .utf8), let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return jsonObj
    }

    var base64urlDecoded: Data? {
        var base64 = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 { base64.append(String(repeating: "=", count: 4 - base64.count % 4)) }
        return Data(base64Encoded: base64)
    }
}

extension Data {
    var base64url: String {
        self.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }
}
