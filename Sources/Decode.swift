import Foundation
import Vapor

/// Failure reasons from decoding a JWT
public enum InvalidToken : CustomStringConvertible, ErrorProtocol {
    /// Decoding the JWT itself failed
    case DecodeError(String)
    
    /// The JWT uses an unsupported algorithm
    case InvalidAlgorithm
    
    /// The issued claim has expired
    case ExpiredSignature
    
    /// The issued claim is for the future
    case ImmatureSignature
    
    /// The claim is for the future
    case InvalidIssuedAt
    
    /// The audience of the claim doesn't match
    case InvalidAudience
    
    /// The issuer claim failed to verify
    case InvalidIssuer
    
    /// Returns a readable description of the error
    public var description:String {
        switch self {
        case .DecodeError(let error):
            return "Decode Error: \(error)"
        case .InvalidIssuer:
            return "Invalid Issuer"
        case .ExpiredSignature:
            return "Expired Signature"
        case .ImmatureSignature:
            return "The token is not yet valid (not before claim)"
        case .InvalidIssuedAt:
            return "Issued at claim (iat) is in the future"
        case InvalidAudience:
            return "Invalid Audience"
        case InvalidAlgorithm:
            return "Unsupported algorithm or incorrect key"
        }
    }
}


/// Decode a JWT
public func decode(jwt:String, algorithms:[Algorithm], verify:Bool = true, audience:String? = nil, issuer:String? = nil) throws -> Payload {
    switch load(jwt: jwt) {
    case let .Success(header, payload, signature, signatureInput):
        if verify {
            if let failure = validateClaims(payload: payload, audience: audience, issuer: issuer) ?? verifySignature(algorithms: algorithms, header: header, signingInput: signatureInput, signature: signature) {
                throw failure
            }
        }
        
        return payload
    case .Failure(let failure):
        throw failure
    }
}

/// Decode a JWT
public func decode(jwt:String, algorithm:Algorithm, verify:Bool = true, audience:String? = nil, issuer:String? = nil) throws -> Payload {
    return try decode(jwt: jwt, algorithms: [algorithm], verify: verify, audience: audience, issuer: issuer)
}

// MARK: Parsing a JWT

enum LoadResult {
    case Success(header:Payload, payload:Payload, signature:Data, signatureInput:String)
    case Failure(InvalidToken)
}

func load(jwt:String) -> LoadResult {
    let segments = jwt.components(separatedBy: ".")
    if segments.count != 3 {
        return .Failure(.DecodeError("Not enough segments"))
    }
    
    let headerSegment = segments[0]
    let payloadSegment = segments[1]
    let signatureSegment = segments[2]
    let signatureInput = "\(headerSegment).\(payloadSegment)"
    
    let headerData = base64decode(input: headerSegment)
    
    if headerData == nil {
        return .Failure(.DecodeError("Header is not correctly encoded as base64"))
    }

    let header = try? JSON(headerData!)
    
    if header == nil {
        return .Failure(.DecodeError("Invalid header"))
    }
    
    let payloadData = base64decode(input: payloadSegment)
    if payloadData == nil {
        return .Failure(.DecodeError("Payload is not correctly encoded as base64"))
    }
    
    let payload = try? JSON(payloadData!)
    if payload == nil {
        return .Failure(.DecodeError("Invalid payload"))
    }
    
    let signature = base64decode(input: signatureSegment)
    if signature == nil {
        return .Failure(.DecodeError("Signature is not correctly encoded as base64"))
    }
    
    return .Success(header:header!, payload:payload!, signature:signature!, signatureInput:signatureInput)
}

// MARK: Signature Verification

func verifySignature(algorithms:[Algorithm], header:Payload, signingInput:String, signature: Data) -> InvalidToken? {
    if let alg = header["alg"].string {
        let matchingAlgorithms = algorithms.filter { algorithm in  algorithm.description == alg }
        let results = matchingAlgorithms.map { algorithm in algorithm.verify(message: signingInput, signature: signature) }
        let successes = results.filter { $0 }
        if successes.count > 0 {
            return nil
        }
        
        return .InvalidAlgorithm
    }
    
    return .DecodeError("Missing Algorithm")
}
