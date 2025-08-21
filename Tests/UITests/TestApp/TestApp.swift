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
            .conditionallyApply { view in
                if #available(iOS 17, *) {
                    view.spezi(delegate)
                }
            }
        }
    }
    
}


//extension View {
//    @ViewBuilder
//    func spezi(_ delegate: TestAppDelegate) -> some View {
//        if let bridge = delegate.bridge {
//            AnyView(bridge.speziInjectionViewModifier.applying(to: self))
//        } else {
//            self
//        }
//    }
//}
//
//
//extension ViewModifier {
//    func applying(to view: some View) -> some View {
//        view.modifier(self)
//    }
//}
