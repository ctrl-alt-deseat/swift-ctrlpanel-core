// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "CtrlpanelCore",
    products: [
        .library(name: "CtrlpanelCore", targets: ["CtrlpanelCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LinusU/JSBridge", from: "1.0.0-alpha.4"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.0.0"),
    ],
    targets: [
        .target(name: "CtrlpanelCore", dependencies: ["JSBridge", "PromiseKit"], path: "Sources"),
        .testTarget(name: "CtrlpanelCoreTests", dependencies: ["CtrlpanelCore"], path: "Tests"),
    ]
)
