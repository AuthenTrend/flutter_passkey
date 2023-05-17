import AuthenticationServices

public class PublicKeyCredentialRequestOptions: NSObject {
    
    enum OptionError: Error {
        case notFound(String)
        case invalidValue(String)
    }
    
    enum AuthenticatorAttachment: String {
        case platform = "platform"
        case crossPlatform = "cross-platform"
    }
    
    let options: [String: Any]

    init(_ jsonObject: [String: Any]) {
        self.options = jsonObject
    }
    
    convenience init (_ jsonString: String) throws {
        self.init(try jsonString.jsonObject)
    }
    
    var challenge: Data {
        get throws {
            guard let challengeStr = self.options["challenge"] as? String, let challenge = challengeStr.base64urlDecoded else {
                throw OptionError.notFound("challenge")
            }
            return challenge
        }
    }
    
    var rpId: String {
        get throws {
            var rpId = ""
            if let rpObj = self.options["rp"] as? [String: Any], let id = rpObj["id"] as? String { rpId = id }
            if let id = self.options["rpId"] as? String { rpId = id }
            if rpId.isEmpty {
                throw OptionError.notFound("rpId")
            }
            return rpId
        }
    }
    
    var userName: String {
        get throws {
            guard let userObj = self.options["user"] as? [String: Any], let userName = userObj["name"] as? String else {
                throw OptionError.notFound("userName")
            }
            return userName
        }
    }
    
    var userId: Data {
        get throws {
            guard let userObj = self.options["user"] as? [String: Any], let id = userObj["id"] as? String, let userId = id.data(using: .utf8) else {
                throw OptionError.notFound("userId")
            }
            return userId
        }
    }
    
    var pubKeyCredParams: [ASAuthorizationPublicKeyCredentialParameters] {
        var _pubKeyCredParams: [ASAuthorizationPublicKeyCredentialParameters] = []
        if let pubKeyCredParamsObj = self.options["pubKeyCredParams"] as? [[String: Any]] {
            for paramObj in pubKeyCredParamsObj {
                if let alg = paramObj["alg"] as? Int {
                    _pubKeyCredParams.append(ASAuthorizationPublicKeyCredentialParameters(algorithm: ASCOSEAlgorithmIdentifier(alg)))
                }
            }
        }
        return _pubKeyCredParams
    }
    
    var authenticatorAttachment: AuthenticatorAttachment? {
        guard let authenticatorSelectionObj = self.options["authenticatorSelection"] as? [String: Any] else { return nil }
        guard let _authenticatorAttachment = authenticatorSelectionObj["authenticatorAttachment"] as? String else { return nil }
        switch _authenticatorAttachment {
        case AuthenticatorAttachment.platform.rawValue:
            return AuthenticatorAttachment.platform
        case AuthenticatorAttachment.crossPlatform.rawValue:
            return AuthenticatorAttachment.crossPlatform
        default:
            return nil
        }
    }
    
    var attestation: ASAuthorizationPublicKeyCredentialAttestationKind? {
        switch self.options["attestation"] as? String {
        case "none":
            return ASAuthorizationPublicKeyCredentialAttestationKind.none
        case "indirect":
            return ASAuthorizationPublicKeyCredentialAttestationKind.indirect
        case "direct":
            return ASAuthorizationPublicKeyCredentialAttestationKind.direct
        case "enterprise":
            return ASAuthorizationPublicKeyCredentialAttestationKind.enterprise
        default:
            return nil
        }
    }
    
    var userVerification: ASAuthorizationPublicKeyCredentialUserVerificationPreference? {
        var _userVerification = ""
        if let authenticatorSelectionObj = self.options["authenticatorSelection"] as? [String: Any], let uv = authenticatorSelectionObj["userVerification"] as? String {
            _userVerification = uv
        }
        else if let uv = self.options["authenticatorSelection"] as? String {
            _userVerification = uv
        }
        switch _userVerification {
        case "discouraged":
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.discouraged
        case "preferred":
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
        case "required":
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.required
        default:
            return nil
        }
    }
    
    var residentKey: ASAuthorizationPublicKeyCredentialResidentKeyPreference? {
        var _residentKey = ""
        if let authenticatorSelectionObj = self.options["authenticatorSelection"] as? [String: Any] {
            if let rk = authenticatorSelectionObj["residentKey"] as? String {
                _residentKey = rk
            }
            else if (authenticatorSelectionObj["requireResidentKey"] as? Bool) == true {
                _residentKey = "required"
            }
        }
        switch _residentKey {
        case "discouraged":
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.discouraged
        case "preferred":
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
        case "required":
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.required
        default:
            return nil
        }
    }
    
    var excludeCredentials: [Data] {
        get {
            var _excludeCredentials: [Data] = []
            if let excludeCredentialsObj = self.options["excludeCredentials"] as? [[String: Any]] {
                for credentialObj in excludeCredentialsObj {
                    if let id = credentialObj["id"] as? String, let data = id.base64urlDecoded {
                        _excludeCredentials.append(data)
                    }
                }
            }
            return _excludeCredentials
        }
    }
    
    var allowCredentials: [Data] {
        get {
            var _allowCredentials: [Data] = []
            if let allowCredentialsObj = self.options["allowCredentials"] as? [[String: Any]] {
                for credentialObj in allowCredentialsObj {
                    if let id = credentialObj["id"] as? String, let data = id.base64urlDecoded {
                        _allowCredentials.append(data)
                    }
                }
            }
            return _allowCredentials
        }
    }
}

extension PublicKeyCredentialRequestOptions.OptionError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notFound(let name):
            return "\(name) not found."
        case .invalidValue(let value):
            return "Invalid value '\(value)'."
        }
    }
}

extension PublicKeyCredentialRequestOptions.OptionError: LocalizedError {
    private var errorDescription: String {
        return self.description
    }
}

extension String {    
    var base64urlDecoded: Data? {
        var base64 = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 { base64.append(String(repeating: "=", count: 4 - base64.count % 4)) }
        return Data(base64Encoded: base64)
    }
    
    var jsonObject: [String: Any] {
        get throws {
            guard let data = self.data(using: .utf8) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON string.", underlyingError: nil))
            }
            let object = try JSONSerialization.jsonObject(with: data)
            guard let jsonObject = object as? [String: Any] else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON string.", underlyingError: nil))
            }
            return jsonObject
        }
    }
}
