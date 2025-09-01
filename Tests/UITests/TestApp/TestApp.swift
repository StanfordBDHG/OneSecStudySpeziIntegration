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
                if #available(iOS 17, *) {
                    StudyButton()
                } else {
                    Text("""
                        You're running on a pre-iOS 17 device.
                        
                        The Spezi integration has not been loaded.
                        
                        If you can see this, everything is fine.
                        """)
                }
            }
            .spezi()
        }
    }
}
