# Update

This fork is not actual anymore, the original repo already supports Linux.

# JSON Web Token

Swift implementation of [JSON Web Token](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32).
Adapted for Vapor framework.
Works on Linux.

## Usage

```swift
import JWT
```

### Encoding a claim

```swift
JWT.encode(payload: ["my": "payload"], algorithm: .HS256("secret"))
```

#### Building a JWT with the builder pattern

```swift
JWT.encode(algorithm: .HS256("secret")) { builder in
  builder.issuer = "fuller.li"
  builder.issuedAt = NSDate()
  builder.customJSON = JSON(["custom": "value"])
}
```

### Decoding a JWT

When decoding a JWT, you must supply one or more algorithms and keys.

```swift
do {
  let payload = try JWT.decode("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.2_8pWJfyPup0YwOXK7g9Dn0cF1E3pdn299t4hSeJy5w", algorithm: .HS256("secret"))
  print(payload)
} catch {
  print("Failed to decode JWT: \(error)")
}
```

When the JWT may be signed with one out of many algorithms or keys:

```swift
try JWT.decode("eyJh...5w", algorithms: [.HS256("secret"), .HS256("secret2"), .HS512("secure")])
```

#### Supported claims

The library supports validating the following claims:

- Issuer (`iss`) Claim
- Expiration Time (`exp`) Claim
- Not Before (`nbf`) Claim
- Issued At (`iat`) Claim
- Audience (`aud`) Claim

### Algorithms

This library supports the following algorithms:

- None - Unsecured JWTs
- HS256 - HMAC using SHA-256 hash algorithm (default)
- HS384 - HMAC using SHA-384 hash algorithm
- HS512 - HMAC using SHA-512 hash algorithm

## License

JSONWebToken is licensed under the BSD license. See [LICENSE](LICENSE) for more info.

