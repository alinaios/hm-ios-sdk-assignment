// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ProductClient",
    platforms: [
        .iOS(.v26),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ProductClient", targets: ["ProductClient"])
    ],
    targets: [
        .target(name: "ProductClient"),
        .testTarget(
            name: "ProductClientTests",
            dependencies: ["ProductClient"]
        )
    ],
    swiftLanguageModes: [.v6]
)
