// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppleGrab",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "AppleGrab",
            targets: ["AppleGrab"]
        ),
    ],
    targets: [
        .target(
            name: "AppleGrab"
        ),
        .testTarget(
            name: "AppleGrabTests",
            dependencies: ["AppleGrab"]
        ),
    ]
)
