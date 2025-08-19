//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit
import SpeziHealthKitBulkExport
import SpeziOneSec
import SwiftUI


final class TestAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: TestAppStandard()) {
            SpeziOneSec(healthExportConfig: .init(
                destination: .temporaryDirectory.appending(path: "urgh"),
                sampleTypes: [],
                timeRange: Date.now..<Date.now
            ))
            HealthKit()
            BulkHealthExporter()
        }
    }
}
