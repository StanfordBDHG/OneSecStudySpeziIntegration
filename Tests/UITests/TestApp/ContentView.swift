//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOneSecInterface
import SwiftUI


@available(iOS 17, *)
struct ContentView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    StudyButton()
                }
                Section {
                    WebViewAlertAndConfimTestButton()
                }
            }
        }
    }
}
