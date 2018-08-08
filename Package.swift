// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "vapor-til-sqlite",
    dependencies: [
        // 3.0.6           2018.07.05
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.6"),
        // 3.0.0-rc.4.0.1  2018.06.21
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc"),
        // 3.0.0-rc.2.2 2018.05.04
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        // 2.0.0-rc.5   2018.06.15
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        // :IMPERIAL: .package(url: "https://github.com/vapor-community/Imperial.git", from: "0.7.1"),
        // :: .package(url: "https://github.com/vapor/crypto.git", from: "3.2.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Leaf", "Authentication"]), 
        // :IMPERIAL: , "Imperial"
        // ::  …, "Crypto", "Random"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        ]
)

