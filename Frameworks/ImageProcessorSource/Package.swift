// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ImageProcessor",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "ImageProcessor", type: .dynamic, targets: ["ImageProcessor"])
    ],
    targets: [
        .target(name: "ImageProcessor"),
        .testTarget(
            name: "ImageProcessorTests",
            dependencies: ["ImageProcessor"]
        )
    ],
    swiftLanguageModes: [.v6]
)
