import Flutter
import UIKit
import AuthenticationServices

@available(iOS 15.0, *)
public class FlutterPasskeyPlugin: NSObject, FlutterPlugin {
    
    enum PluginError: Error {
        case unknownError
        case notFound(String)
        case unknownCredentialType(AnyObject)
        case excludedCredentialExists
    }
    
    class AuthCtrlDelegate: NSObject, ASAuthorizationControllerDelegate {
        private let semaphore = DispatchSemaphore(value: 0)
        private var result: (controller: ASAuthorizationController, authorization: ASAuthorization?, error: Error?)?
        
        func getResult() throws -> (controller: ASAuthorizationController, authorization: ASAuthorization?, error: Error?) {
            semaphore.wait()
            guard let ret = result else {
                throw PluginError.unknownError
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
    
    private func getPlatformPublicKeyCredentials() -> [String] {
        return (UserDefaults.standard.object(forKey: "platformPublicKeyCredentials") as? [String]) ?? []
    }
    
    private func savePlatformPublicKeyCredential(_ credential: ASAuthorizationCredential) {
        var credentialID = ""
        if let credential = credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            credentialID = credential.credentialID.base64url
        }
        else if let credential = credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            credentialID = credential.credentialID.base64url
        }
        if credentialID.isEmpty { return }
        
        var credentials = getPlatformPublicKeyCredentials()
        if !credentials.contains(credentialID) {
            credentials.append(credentialID)
            UserDefaults.standard.set(credentials, forKey: "platformPublicKeyCredentials")
        }
    }
    
    private func handlePlatformExcludedCredentials(_ options: PublicKeyCredentialRequestOptions) throws {
        let excludeCredentials = options.excludeCredentials
        guard excludeCredentials.count > 0 else { return }
        let credentials = getPlatformPublicKeyCredentials()
        for credential in credentials {
            for excludeCredential in excludeCredentials {
                if excludeCredential.base64url == credential {
                    throw PluginError.excludedCredentialExists
                }
            }
        }
    }
    
    private func findPlatformCredentials(_ credentials: [Data]) -> [Data] {
        guard credentials.count > 0 else { return [] }
        var foundCredentials: [Data] = []
        let platformCredentials = getPlatformPublicKeyCredentials()
        for credential in credentials {
            for platformCredential in platformCredentials {
                if credential.base64url == platformCredential {
                    foundCredentials.append(credential)
                    break
                }
            }
        }
        return foundCredentials
    }
    
    private func createPlatformPublicKeyCredentialRegistrationRequest(_ options: PublicKeyCredentialRequestOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest {
        let rpId = try options.rpId
        let challenge = try options.challenge
        let userName = try options.userName
        let userId = try options.userId
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let registrationRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: userName, userID: userId)
        /*// Passkeys do not support attestation.
        if let attestationPreference = options.attestation {
            registrationRequest.attestationPreference = attestationPreference
        }
        */
        if let userVerificationPreference = options.userVerification {
            registrationRequest.userVerificationPreference = userVerificationPreference
        }
        // ISSUE: Currently ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest doesn't support excludedCredentials.
        // WORKAROUND: Handling excludeCredentials by plugin self.
        try handlePlatformExcludedCredentials(options)
        return registrationRequest
    }
    
    private func createSecurityKeyPublicKeyCredentialRegistrationRequest(_ options: PublicKeyCredentialRequestOptions) throws -> ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest {
        let rpId = try options.rpId
        let challenge = try options.challenge
        let userName = try options.userName
        let userId = try options.userId
        let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let registrationRequest = securityKeyProvider.createCredentialRegistrationRequest(challenge: challenge, displayName: userName, name: userName, userID: userId)
        registrationRequest.credentialParameters = options.pubKeyCredParams
        if let attestationPreference = options.attestation {
            registrationRequest.attestationPreference = attestationPreference
        }
        if let userVerificationPreference = options.userVerification {
            registrationRequest.userVerificationPreference = userVerificationPreference
        }
        if let residentKeyPreference = options.residentKey {
            registrationRequest.residentKeyPreference = residentKeyPreference
        }
        let excludedCredentials = options.excludeCredentials
        if excludedCredentials.count > 0 {
            registrationRequest.excludedCredentials = excludedCredentials.map { ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(credentialID: $0, transports: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported) }
        }
        return registrationRequest
    }
    
    private func createPlatformPublicKeyCredentialAssertionRequest(_ options: PublicKeyCredentialRequestOptions) throws -> ASAuthorizationPlatformPublicKeyCredentialAssertionRequest {
        let rpId = try options.rpId
        let challenge = try options.challenge
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let assertionRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
        if let userVerificationPreference = options.userVerification {
            assertionRequest.userVerificationPreference = userVerificationPreference
        }
        let allowedCredentials = options.allowCredentials
        // ISSUE: if allowedCredentials are different from SecurityKeyPublicKeyCredentialAssertionRequest, iOS Passkeys will hang on processing in background.
        if allowedCredentials.count > 0 {
            assertionRequest.allowedCredentials = allowedCredentials.map { ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: $0) }
        }
        return assertionRequest
    }
    
    private func createSecurityKeyPublicKeyCredentialAssertionRequest(_ options: PublicKeyCredentialRequestOptions) throws -> ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest {
        let rpId = try options.rpId
        let challenge = try options.challenge
        let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let assertionRequest = securityKeyProvider.createCredentialAssertionRequest(challenge: challenge)
        if let userVerificationPreference = options.userVerification {
            assertionRequest.userVerificationPreference = userVerificationPreference
        }
        let allowedCredentials = options.allowCredentials
        if allowedCredentials.count > 0 {
            assertionRequest.allowedCredentials = allowedCredentials.map { ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(credentialID: $0, transports: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported) }
        }
        return assertionRequest
    }
    
    private func getPresentationContextProvider() throws -> ASAuthorizationControllerPresentationContextProviding {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        guard var topController = keyWindow?.rootViewController else {
            throw PluginError.notFound("Root view controller")
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        if let nav = topController as? UINavigationController {
            topController = nav.visibleViewController ?? topController
        }
        guard let contextProvider = topController as? ASAuthorizationControllerPresentationContextProviding else {
            throw PluginError.notFound("Presentation context provider")
        }
        return contextProvider
    }
    
    private func requestCredential(_ authorizationRequests: [ASAuthorizationRequest]) throws -> ASAuthorizationCredential {
        let authController = ASAuthorizationController(authorizationRequests: authorizationRequests)
        let authCtrlDelete = AuthCtrlDelegate()
        let contextProvider = try getPresentationContextProvider()
        authController.delegate = authCtrlDelete
        authController.presentationContextProvider = contextProvider
        authController.performRequests()
        
        let result = try authCtrlDelete.getResult()
        guard result.error == nil else {
            throw result.error!
        }
        guard let authorization = result.authorization else {
            throw PluginError.notFound("Credential")
        }
        // ISSUE: Currently ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest doesn't support excludedCredentials.
        // WORKAROUND: Handling excludeCredentials by plugin self.
        // SIDE-EFFECT: Assertions may come from another device by scanning QR code, in that case, the credential SHALL NOT be saved, but there is no way to know the assertion source. This leads that credential registration fails if excludedCredentials includes the credential.
        savePlatformPublicKeyCredential(authorization.credential)
        return authorization.credential
    }
    
    private func generateCredentialRegistrationResponse(_ credentialID: Data, _ rawClientDataJSON: Data, _ rawAttestationObject: Data? = nil) throws -> [String: Any] {
        let response = [
            "id": credentialID.base64url,
            "rawId": credentialID.base64url,
            "type": "public-key",
            "response": [
                "attestationObject": rawAttestationObject?.base64url ?? "null",
                "clientDataJSON": rawClientDataJSON.base64url,
                "getAuthenticatorData": [:] as [String : Any],
                "getPublicKey": [:] as [String : Any],
                "getPublicKeyAlgorithm": [:] as [String : Any],
                "getTransports": [:] as [String : Any],
            ] as [String : Any],
            "getClientExtensionResults": [:] as [String : Any]
        ] as [String : Any]
        return response
    }
    
    private func generateCredentialAssertionResponse(_ credentialID: Data, _ userID: Data, _ signature: Data, _ rawAuthenticatorData: Data, _ rawClientDataJSON: Data) throws -> [String: Any] {
        let response = [
            "id": credentialID.base64url,
            "rawId": credentialID.base64url,
            "type": "public-key",
            "response": [
                "authenticatorData": rawAuthenticatorData.base64url,
                "signature": signature.base64url,
                "userHandle": userID.base64url,
                "clientDataJSON": rawClientDataJSON.base64url,
            ] as [String : Any],
            "getClientExtensionResults": [:] as [String : Any]
        ] as [String : Any]
        return response
    }
    
    private func generateCredentialResponse(_ credential: ASAuthorizationCredential) throws -> [String: Any] {
        var response: [String: Any] = [:]
        switch (credential) {
        case is ASAuthorizationPlatformPublicKeyCredentialRegistration:
            let credential = credential as! ASAuthorizationPlatformPublicKeyCredentialRegistration
            response = try generateCredentialRegistrationResponse(credential.credentialID, credential.rawClientDataJSON, credential.rawAttestationObject)
        case is ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            let credential = credential as! ASAuthorizationSecurityKeyPublicKeyCredentialRegistration
            response = try generateCredentialRegistrationResponse(credential.credentialID, credential.rawClientDataJSON, credential.rawAttestationObject)
        case is ASAuthorizationPlatformPublicKeyCredentialAssertion:
            let credential = credential as! ASAuthorizationPlatformPublicKeyCredentialAssertion
            response = try generateCredentialAssertionResponse(credential.credentialID, credential.userID, credential.signature, credential.rawAuthenticatorData, credential.rawClientDataJSON)
        case is ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let credential = credential as! ASAuthorizationSecurityKeyPublicKeyCredentialAssertion
            response = try generateCredentialAssertionResponse(credential.credentialID, credential.userID, credential.signature, credential.rawAuthenticatorData, credential.rawClientDataJSON)
        default:
            throw PluginError.unknownCredentialType(credential)
        }
        return response
    }
    
    private func requestCredentialRegistration(_ options: PublicKeyCredentialRequestOptions) throws -> String {
        var authorizationRequests: [ASAuthorizationRequest] = []
        switch options.authenticatorAttachment {
        case .platform:
            authorizationRequests.append(try createPlatformPublicKeyCredentialRegistrationRequest(options))
        case .crossPlatform:
            authorizationRequests.append(try createSecurityKeyPublicKeyCredentialRegistrationRequest(options))
        default:
            authorizationRequests.append(try createPlatformPublicKeyCredentialRegistrationRequest(options))
            authorizationRequests.append(try createSecurityKeyPublicKeyCredentialRegistrationRequest(options))
        }
        let credential = try requestCredential(authorizationRequests)
        let response = try generateCredentialResponse(credential)
        return try response.jsonString
    }
    
    private func requestCredentialAssertion(_ options: PublicKeyCredentialRequestOptions) throws -> String {
        var authorizationRequests: [ASAuthorizationRequest] = []
        switch options.authenticatorAttachment {
        case .platform:
            authorizationRequests.append(try createPlatformPublicKeyCredentialAssertionRequest(options))
        case .crossPlatform:
            authorizationRequests.append(try createSecurityKeyPublicKeyCredentialAssertionRequest(options))
        default:
            authorizationRequests.append(try createPlatformPublicKeyCredentialAssertionRequest(options))
            /* ISSUE:
             * iOS(16.4.1) will show QR code for Passkeys if adding both PlatformPublicKeyCredentialAssertionRequest and
             * SecurityKeyPublicKeyCredentialAssertionRequest into authorizationRequests and allowCredentials is not empty.
             * It seems that allowCredentials cannot be found in the platform credeintials, but it will work if removing
             * SecurityKeyPublicKeyCredentialAssertionRequest from authorizationRequests, that means allowCredentials can be found.
             */
            // WORKAROUND: Adding SecurityKeyPublicKeyCredentialAssertionRequest if there is no any platform credeintial can be found in allowCredentials. But the saved platform credentials are not all on the device, due to there is no way can get all platform credentials from iOS.
            if findPlatformCredentials(options.allowCredentials).count == 0 {
                authorizationRequests.append(try createSecurityKeyPublicKeyCredentialAssertionRequest(options))
            }
        }
        let credential = try requestCredential(authorizationRequests)
        let response = try generateCredentialResponse(credential)
        return try response.jsonString
    }
    
    private func createCredential(_ options: String, _ callback: @escaping (_ credential: String?, _ error: Error?) -> Void) {
        Task {
            do {
                let credential = try requestCredentialRegistration(PublicKeyCredentialRequestOptions(options))
                callback(credential, nil)
            } catch {
                callback(nil, error)
            }
        }
    }
    
    private func getCredential(_ options: String, _ callback: @escaping (_ credential: String?, _ error: Error?) -> Void) {
        Task {
            do {
                let credential = try requestCredentialAssertion(PublicKeyCredentialRequestOptions(options))
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
                        result(FlutterError(code: String(describing: type(of: err)), message: "\(err)", details: nil))
                        return
                    }
                    result(credential!)
                }
            }
            else {
                result(FlutterError(code: "CreateCredentialError", message: "Options not found", details: nil))
            }
        case "getCredential":
            if let args = call.arguments as? Dictionary<String, Any>, let options = args["options"] as? String {
                getCredential(options) { credential, error in
                    if let err = error {
                        result(FlutterError(code: String(describing: type(of: err)), message: "\(err)", details: nil))
                        return
                    }
                    result(credential!)
                }
            }
            else {
                result(FlutterError(code: "GetCredentialError", message: "Options not found", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FlutterPasskeyPlugin.PluginError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknownError:
            return "Unknown error."
        case .notFound(let name):
            return "\(name) not found."
        case .unknownCredentialType(let object):
            return "Unknown credential type \(String(describing: type(of: object)))."
        case .excludedCredentialExists:
            return "One of the excluded credentials exists on the local device."
        }
    }
}

extension FlutterPasskeyPlugin.PluginError: LocalizedError {
    private var errorDescription: String {
        return self.description
    }
}

extension FlutterViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension Data {
    var base64url: String {
        self.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }
}

extension Dictionary where Key == String {
    var jsonString: String {
        get throws {
            let data = try JSONSerialization.data(withJSONObject: self)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON data.", underlyingError: nil))
            }
            return jsonString
        }
    }
}
