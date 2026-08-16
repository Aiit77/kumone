// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Kumone",
    defaultLocalization: "zh-Hans",
    platforms: [.macOS("15.0")],
    products: [
        .executable(name: "Kumone", targets: ["Kumone"]),
    ],
    targets: [
        .executableTarget(
            name: "Kumone",
            path: "Sources/Kumone",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
