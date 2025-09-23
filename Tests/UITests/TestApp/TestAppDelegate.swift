//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziOneSecInterface
import SwiftUI


final class TestAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? // swiftlint:disable:this discouraged_optional_collection
    ) -> Bool {
        let cal = Calendar.current
        SpeziOneSecInterface.initialize(
            application,
            launchOptions: launchOptions,
            healthExportConfig: .init(
                destination: FileManager.default.temporaryDirectory,
                sampleTypes: sampleTypes,
                timeRange: cal.date(byAdding: .year, value: -1, to: .now)!..<Date.now,
            ) { urls in
                Task {
                    try await self.handleHealthExportUrls(urls)
                }
            }
        )
        print(Bundle.main.bundlePath)
        let contents = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
        for name in contents {
            print("- \(name)")
        }
        return true
    }
    
    
    private func handleHealthExportUrls<S: AsyncSequence>(_ urls: S) async throws where S.Element == URL {
        for try await url in urls {
            print("Did create export batch \(url)")
        }
    }
    
    
    private var sampleTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKCategoryType(.sleepAnalysis)
        ]
        if #available(iOS 18.0, *) {
            types.insert(.stateOfMindType())
        }
        return types
    }
}
