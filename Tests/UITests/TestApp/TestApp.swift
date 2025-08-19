//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziOneSec
import SwiftUI


@main
struct UITestsApp: App {
    @ApplicationDelegateAdaptor private var delegate: TestAppDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .spezi(delegate)
        }
    }
}
