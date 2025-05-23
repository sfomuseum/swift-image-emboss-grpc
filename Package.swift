// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageEmbosser",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "2.2.1"),
        .package(url: "https://github.com/grpc/grpc-swift-protobuf.git", from: "1.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift-nio-transport.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/sfomuseum/swift-image-emboss", from: "0.0.5"),
        .package(url: "https://github.com/sfomuseum/swift-coreimage-image.git", from: "1.1.0"),
        .package(url: "https://github.com/sfomuseum/swift-sfomuseum-logger.git", from: "1.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "image-emboss-grpc-server",
            dependencies: [
                .product(name: "GRPCCore", package: "grpc-swift"),
                .product(name: "GRPCNIOTransportHTTP2", package: "grpc-swift-nio-transport"),
                .product(name: "GRPCProtobuf", package: "grpc-swift-protobuf"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ImageEmboss", package: "swift-image-emboss"),
                .product(name: "CoreImageImage", package: "swift-coreimage-image"),
                .product(name: "SFOMuseumLogger", package: "swift-sfomuseum-logger"),
            ],
        )
    ]
)
