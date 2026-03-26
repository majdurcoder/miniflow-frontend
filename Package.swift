// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Miniflow",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Miniflow",
            path: "Sources/Miniflow"
        )
    ]
)
