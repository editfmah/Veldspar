// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Veldspar",
    products: [
        .library        (name: "VeldsparCore",     targets: ["VeldsparCore"]),
        .executable     (name: "veldspard",        targets: ["veldspard"]),
        .executable     (name: "miner",            targets: ["miner"]),
        .executable     (name: "simplewallet",     targets: ["simplewallet"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .exact("0.8.7")),
        .package(url: "https://gitlab.com/katalysis/Ed25519.git", .exact("0.2.1")),
        .package(url: "https://github.com/sharksync/SWSQLite.git", .exact("1.0.11")),
        .package(url: "https://github.com/vapor/vapor.git", .exact("3.0.8")),
        ],
    targets: [
        .target(
            name: "veldspard",
            dependencies: ["CryptoSwift","Vapor","SWSQLite","VeldsparCore","Ed25519"],
            path: "./Sources/daemon"),
        .target(
            name: "miner",
            dependencies: ["CryptoSwift","Vapor","SWSQLite","VeldsparCore","Ed25519"],
            path: "./Sources/miner"),
        .target(
            name: "simplewallet",
            dependencies: ["CryptoSwift","Vapor","SWSQLite","VeldsparCore","Ed25519"],
            path: "./Sources/simplewallet"),
        .target(
            name: "VeldsparCore",
            dependencies: ["CryptoSwift","Vapor","SWSQLite","Ed25519"],
            path: "./Sources/core"),
        ]
)
