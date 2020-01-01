// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftUTI",
    products: [
        .library(
            name: "SwiftUTI",
            targets: ["SwiftUTI"]
        )
    ],
    targets: [
        // Our package contains two targets, one for our library
        // code, and one for our tests:
        .target(name: "SwiftUTI"),
        .testTarget(
            name: "SwiftUTITests",
            dependencies: ["SwiftUTI"]
        )
    ]
)
