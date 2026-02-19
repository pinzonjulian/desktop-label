// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesktopLabel",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "DesktopLabel",
            path: "Sources"
        )
    ]
)
