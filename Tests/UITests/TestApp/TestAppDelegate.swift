//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import BridgeInterface
import SwiftUI


final class TestAppDelegate: NSObject, UIApplicationDelegate {
    private(set) var bridge: (any BridgeInterfaceProtocol.Type)?
    
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? // swiftlint:disable:this discouraged_optional_collection
    ) -> Bool {
        if #available(iOS 17, *),
           let url = Bundle.main.privateFrameworksURL?.appending(component: "BridgeFramework.framework"),
           let bundle = Bundle(url: url),
           bundle.load(),
           let bridge = bundle.principalClass as? any BridgeInterfaceProtocol.Type {
            self.bridge = bridge
            bridge.initialize(application: application, launchOptions: launchOptions)
        }
        return true
    }
}
