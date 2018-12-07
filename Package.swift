// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "vapor-til-sqlite",
    dependencies: [
        // 3.1.0   2018.09.19
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),
        // 3.0.0   2018.07.17
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        // 3.0.2   2018.10.30
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        // 2.0.1   2018.08.14
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        // :IMPERIAL: .package(url: "https://github.com/vapor-community/Imperial.git", from: "0.7.2"),
        // 3.3.0   2018.09.25
        //.package(url: "https://github.com/vapor/crypto.git", from: "3.3.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Leaf", "Authentication"]), 
        // :IMPERIAL: , "Imperial"
        // ::  …, "Crypto", "Random"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        ]
)

