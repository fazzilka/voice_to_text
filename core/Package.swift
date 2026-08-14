// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VoiceToTextCore",
    products: [
        .library(name: "VoiceToTextCore", targets: ["VoiceToTextCore"]),
        .executable(name: "VoiceToTextCoreChecks", targets: ["VoiceToTextCoreChecks"]),
    ],
    targets: [
        .target(name: "VoiceToTextCore"),
        .executableTarget(
            name: "VoiceToTextCoreChecks",
            dependencies: ["VoiceToTextCore"]
        ),
    ]
)
