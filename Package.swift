// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageEmbossGRPC",
    products: [
        .library(
            name: "ImageEmbossGRPC",
            targets: ["ImageEmbossGRPC"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/sfomuseum/swift-image-emboss", from: "0.0.5"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.25.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.29.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/sfomuseum/swift-coreimage-image.git", from: "1.1.0"),
        .package(url: "https://github.com/sfomuseum/swift-grpc-server.git", from: "0.0.4"),
        .package(url: "https://github.com/sfomuseum/swift-sfomuseum-logger.git", from: "1.0.1"),
        // .package(path: "/usr/local/sfomuseum/swift-sfomuseum-logger")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ImageEmbossGRPC",
            dependencies: [
                .product(name: "ImageEmboss", package: "swift-image-emboss"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "CoreImageImage", package: "swift-coreimage-image"),
                .product(name: "GRPCServerLogger", package: "swift-grpc-server"),
            ],
            exclude: ["embosser.proto"]
        ),
        .executableTarget(
            name: "image-emboss-grpc-server",
            dependencies: [
                "ImageEmbossGRPC",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ImageEmboss", package: "swift-image-emboss"),
                .product(name: "SFOMuseumLogger", package: "swift-sfomuseum-logger"),
                .product(name: "GRPCServer", package: "swift-grpc-server")
            ],
            path: "Scripts"
	)
    ]
)
