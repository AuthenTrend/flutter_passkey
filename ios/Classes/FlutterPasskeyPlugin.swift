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
            // let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration
            // let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion
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
    
    private func requestCredential(_ options: String, _ isCreation: Bool) throws -> String {
        guard let jsonObj = options.jsonObject else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1002, userInfo: [NSLocalizedDescriptionKey: "Options not found"])
        }
        guard let challengeStr = jsonObj["challenge"] as? String, let challenge = challengeStr.base64urlDecoded else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1005, userInfo: [NSLocalizedDescriptionKey: "Challenge not found"])
        }
        var rpId = ""
        if let rpObj = jsonObj["rp"] as? [String: Any], let id = rpObj["id"] as? String { rpId = id }
        if let id = jsonObj["rpId"] as? String { rpId = id }
        if rpId.isEmpty {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1003, userInfo: [NSLocalizedDescriptionKey: "RP id not found"])
        }
        
        var platformKeyRequest: ASAuthorizationRequest
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        if isCreation {
            guard let userObj = jsonObj["user"] as? [String: Any], let id = userObj["id"] as? String, let userName = userObj["name"] as? String, let userId = id.data(using: .utf8) else {
                throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1004, userInfo: [NSLocalizedDescriptionKey: "User id or name not found"])
            }
            platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: userName, userID: userId)
        }
        else {
            platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
        }
        
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
        guard let contextProvider = topController as? ASAuthorizationControllerPresentationContextProviding else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1007, userInfo: [NSLocalizedDescriptionKey: "Presentation context provider not found"])
        }
        
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        let authCtrlDelete = AuthCtrlDelegate()
        authController.delegate = authCtrlDelete
        authController.presentationContextProvider = contextProvider
        authController.performRequests()
        
        var response: [String: Any] = [:]
        guard let result = try? authCtrlDelete.getResult() else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1000, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if let error = result.error {
            throw error
        }
        guard let authorization = result.authorization else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1008, userInfo: [NSLocalizedDescriptionKey: "Credential not found"])
        }
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            response = [
                "id": credential.credentialID.base64url,
                "rawId": credential.credentialID.base64url,
                "type": "public-key",
                "response": [
                    "attestationObject": credential.rawAttestationObject?.base64url ?? "null",
                    "clientDataJSON": credential.rawClientDataJSON.base64url,
                    "getAuthenticatorData": [:],
                    "getPublicKey": [:],
                    "getPublicKeyAlgorithm": [:],
                    "getTransports": [:],
                ],
                "getClientExtensionResults": [:]
            ]
        }
        else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            response = [
                "id": credential.credentialID.base64url,
                "rawId": credential.credentialID.base64url,
                "type": "public-key",
                "response": [
                    "authenticatorData": credential.rawAuthenticatorData.base64url,
                    "signature": credential.signature.base64url,
                    "userHandle": credential.userID.base64url,
                    "clientDataJSON": credential.rawClientDataJSON.base64url,
                ],
                "getClientExtensionResults": [:]
            ]
        }
        else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1009, userInfo: [NSLocalizedDescriptionKey: "Unknown credential type"])
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: response), let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "FlutterPasskeyPlugin", code: 0x1010, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        return jsonString
    }
    
    private func createCredential(_ options: String, _ callback: @escaping (_ credential: String?, _ error: Error?) -> Void) {
        Task {
            do {
                let credential = try requestCredential(options, true)
                callback(credential, nil)
            } catch {
                callback(nil, error)
            }
        }
    }
    
    private func getCredential(_ options: String, _ callback: @escaping (_ credential: String?, _ error: Error?) -> Void) {
        Task {
            do {
                let credential = try requestCredential(options, false)
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
