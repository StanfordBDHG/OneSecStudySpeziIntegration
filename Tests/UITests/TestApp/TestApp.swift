//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Observation
import SpeziOneSecInterface
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor private var delegate: TestAppDelegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if #available(iOS 16, *) { // swiftlint:disable:this deployment_target
                    NavigationStack {
                        ContentView()
                    }
                } else {
                    NavigationView {
                        ContentView()
                    }
                }
            }
            .spezi()
        }
    }
}
