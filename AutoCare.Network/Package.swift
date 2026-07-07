// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AutoCare.Network",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AutoCare.Network",
            targets: ["AutoCare.Network"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
        .package(url: "https://github.com/kean/Pulse.git", from: "5.1.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", branch: "master")
    ],
    targets: [
        .target(
            name: "AutoCare.Network",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Pulse", package: "Pulse"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ],
            path: "Sources/AutoCare.Network"
        ),
        .testTarget(
            name: "AutoCare.NetworkTests",
            dependencies: ["AutoCare.Network"],
            path: "Tests/AutoCare.NetworkTests"
        )
    ]
)
