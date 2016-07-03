import PackageDescription

let package = Package(
    name: "JWT",
    dependencies: [
        .Package(url: "https://github.com/qutheory/vapor.git", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/open-swift/S4.git", majorVersion: 0, minor: 10),
        .Package(url: "https://github.com/CryptoKitten/HMAC.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/CryptoKitten/SHA2.git", majorVersion: 0, minor: 7)
        ]
)