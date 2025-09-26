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
                timeRange: cal.date(byAdding: .year, value: -1, to: .now)!..<Date.now, // swiftlint:disable:this force_unwrapping
                didStartExport: handleSpeziHealthExportDidStart,
                didEndExport: handleSpeziHealthExportDidEnd
            )
        )
        return true
    }
    
    private func handleSpeziHealthExportDidStart<S: AsyncSequence>(_ urls: S) where S.Element == URL {
        Task {
            for try await url in urls {
                print("Did create export batch \(url)")
            }
        }
    }
    
    private func handleSpeziHealthExportDidEnd() {
        print("Health Export complete")
    }
}
