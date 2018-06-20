// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "vapor-til-sqlite",
    dependencies: [
        // 3.0.5       2018.06.19
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.5"),
        // 3.0.0-rc.4  2018.06.19
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc"),
        // 3.0.0-rc.2.2 2018.05.04
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        // 2.0.0-rc.5   2018.06.15
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Leaf", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
        ]
)

