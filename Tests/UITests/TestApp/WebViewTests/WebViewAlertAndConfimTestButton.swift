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
struct WebViewAlertAndConfimTestButton: View {
    @Environment(SpeziOneSecModule.self) private var speziOneSec
    
    @State private var isSheetPresented = false
    
    var body: some View {
        Button("Test Alert/Confirm") {
            speziOneSec.surveyUrl = Bundle.main.url(forResource: "alert-confirm-test", withExtension: "html")
//            speziOneSec.surveyUrl = try! URL("https://stanford.edu", strategy: .url) // swiftlint:disable:this force_try
            isSheetPresented = true
        }
        .sheet(isPresented: $isSheetPresented) {
            speziOneSec.makeSpeziOneSecSheet()
        }
    }
}
