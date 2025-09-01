// swift-tools-version:6.0

//
// This source file is part of the SpeziOneSec open source project
// 
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription


let package = Package(
    name: "SpeziOneSec",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SpeziOneSec", type: .dynamic, targets: ["SpeziOneSec"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordBDHG/OneSecStudySpeziIntegrationInterface.git", revision: "969133eac91716908c27766df721403cfb67e5cf"),
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.9.2"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.2.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziHealthKit.git", from: "1.2.3"),
        .package(url: "https://github.com/StanfordBDHG/HealthKitOnFHIR.git", from: "1.1.2"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage.git", from: "2.1.1")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziOneSec",
            dependencies: [
                .product(name: "SpeziOneSecInterface", package: "OneSecStudySpeziIntegrationInterface"),
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziHealthKit", package: "SpeziHealthKit"),
                .product(name: "SpeziHealthKitBulkExport", package: "SpeziHealthKit"),
                .product(name: "HealthKitOnFHIR", package: "HealthKitOnFHIR"),
                .product(name: "SpeziLocalStorage", package: "SpeziStorage")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziOneSecTests",
            dependencies: [
                .target(name: "SpeziOneSec")
            ],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
