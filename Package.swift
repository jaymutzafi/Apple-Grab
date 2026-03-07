// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FlutterGrabKit",
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
            name: "AppleGrab",
            path: "packages/apple_grab_sdk/Sources/AppleGrab"
        ),
        .testTarget(
            name: "AppleGrabTests",
            dependencies: ["AppleGrab"],
            path: "packages/apple_grab_sdk/Tests/AppleGrabTests"
        ),
    ]
)
