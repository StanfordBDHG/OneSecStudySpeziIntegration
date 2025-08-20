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
        .library(name: "SpeziOneSec", targets: ["SpeziOneSec"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", branch: "lukas/alternate-injection"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.2.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziHealthKit.git", from: "1.2.3"),
        .package(url: "https://github.com/StanfordBDHG/HealthKitOnFHIR.git", from: "1.1.2"),
        .package(url: "https://github.com/StanfordSpezi/SpeziStorage.git", from: "2.1.1"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", from: "1.12.1")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziOneSec",
            dependencies: [
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "SpeziFoundation", package: "SpeziFoundation"),
                .product(name: "SpeziHealthKit", package: "SpeziHealthKit"),
                .product(name: "SpeziHealthKitBulkExport", package: "SpeziHealthKit"),
                .product(name: "HealthKitOnFHIR", package: "HealthKitOnFHIR"),
                .product(name: "SpeziLocalStorage", package: "SpeziStorage"),
                .product(name: "SpeziViews", package: "SpeziViews")
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
