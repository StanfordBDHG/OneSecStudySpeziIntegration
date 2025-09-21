//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@_spi(APISupport)
import SpeziOneSecInterface
import SwiftUI


@available(iOS 17, *)
struct ContentView: View {
    @Environment(SpeziOneSecModule.self) private var speziOneSec
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    StudyButton()
                    Button("Trigger Health Export") {
                        Task {
                            try await speziOneSec.triggerHealthExport(forceSessionReset: true)
                        }
                    }
                }
                Section {
                    WebViewAlertAndConfimTestButton()
                }
            }
        }
    }
}
