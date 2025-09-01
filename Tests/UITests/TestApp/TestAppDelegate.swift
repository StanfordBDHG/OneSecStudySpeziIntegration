//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOneSecInterface
import SwiftUI


final class TestAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? // swiftlint:disable:this discouraged_optional_collection
    ) -> Bool {
        SpeziOneSecInterface.initialize(
            application,
            launchOptions: launchOptions,
            healthExportConfig: .init(
                destination: FileManager.default.temporaryDirectory,
                sampleTypes: [],
                timeRange: Date.now..<Date.now
            ) { urls in
                Task {
                    try await self.handleHealthExportUrls(urls)
                }
            }
        )
        return true
    }
    
    
    private func handleHealthExportUrls<S: AsyncSequence>(_ urls: S) async throws where S.Element == URL {
        for try await url in urls {
            print("Did create export batch \(url)")
        }
    }
}
