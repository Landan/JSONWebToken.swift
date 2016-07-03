import Foundation
import HMAC
import SHA2
import Vapor

public typealias Payload = JSON

/// The supported Algorithms
public enum Algorithm : CustomStringConvertible {
    /// No Algorithm, i-e, insecure
    case None
    
    /// HMAC using SHA-256 hash algorithm
    case HS256(String)
    
    /// HMAC using SHA-384 hash algorithm
    case HS384(String)
    
    /// HMAC using SHA-512 hash algorithm
    case HS512(String)
    
    static func algorithm(name:String, key:String?) -> Algorithm? {
        if name == "none" {
            if key != nil {
                return nil  // We don't allow nil when we configured a key
            }
            return Algorithm.None
        } else if let key = key {
            if name == "HS256" {
                return .HS256(key)
            } else if name == "HS384" {
                return .HS384(key)
            } else if name == "HS512" {
                return .HS512(key)
            }
        }
        
        return nil
    }
    
    public var description:String {
        switch self {
        case .None:
            return "none"
        case .HS256:
            return "HS256"
        case .HS384:
            return "HS384"
        case .HS512:
            return "HS512"
        }
    }
    
    /// Sign a message using the algorithm
    func sign(message:String) -> String {
        func signHS<T: HashProtocol>(key:String, variant: T.Type) -> String {
            let keyData = key.data
            let messageData = message.data

            let result = HMAC<T>.authenticate(message: messageData.bytes, withKey: keyData.bytes)
            return base64encode(input: Data(result))
        }
        
        switch self {
        case .None:
            return ""
            
        case .HS256(let key):
            return signHS(key: key, variant: SHA2<SHA256>.self)
            
        case .HS384(let key):
            return signHS(key: key, variant: SHA2<SHA384>.self)
            
        case .HS512(let key):
            return signHS(key: key, variant: SHA2<SHA512>.self)
        }
    }
    
    /// Verify a signature for a message using the algorithm
    func verify(message:String, signature: Data) -> Bool {
        return sign(message: message) == base64encode(input: signature)
    }
}

// MARK: Encoding

/*** Encode a payload
 - parameter payload: The payload to sign
 - parameter algorithm: The algorithm to sign the payload with
 - returns: The JSON web token as a String
 */
public func encode(payload:Payload, algorithm: Algorithm) -> String {
    func encodeJSON(payload:Payload) -> String? {
        return base64encode(input: payload.data)
    }
    
    let header = encodeJSON(payload:
        JSON([
            "typ": "JWT",
            "alg": algorithm.description
            ]))!
    let payload = encodeJSON(payload: payload)!
    let signingInput = "\(header).\(payload)"
    let signature = algorithm.sign(message: signingInput)
    return "\(signingInput).\(signature)"
}

public class PayloadBuilder {
    public var issuer: String?
    public var audience: String?
    public var expiration: NSDate?
    public var notBefore:NSDate?
    public var issuedAt:NSDate?
    public var customJSON: JSON?
}

public func encode(algorithm:Algorithm, closure:((PayloadBuilder) -> ())) -> String {
    let builder = PayloadBuilder()
    closure(builder)
    
    var mainJSON = [String: JSONRepresentable]()
    if let issuer = builder.issuer {
        mainJSON = ["iss": issuer]
    }
    
    if let audience = builder.audience {
        mainJSON["aud"] = audience
    }
    
    if let expiration = builder.expiration {
        mainJSON["exp"] = expiration.timeIntervalSince1970
    }
    
    if let notBefore = builder.notBefore {
        mainJSON["nbf"] = notBefore.timeIntervalSince1970
    }
    
    if let issuedAt = builder.issuedAt {
        mainJSON["iat"] = issuedAt.timeIntervalSince1970
    }
    
    if let customJSON = builder.customJSON {
        for item in customJSON.dictionary! {
            mainJSON[item.key] = item.value
        }
    }

    return encode(payload:JSON(mainJSON), algorithm: algorithm)
}
