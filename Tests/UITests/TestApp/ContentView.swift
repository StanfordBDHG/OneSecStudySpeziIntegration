//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable all

//import SpeziOneSec
import SwiftUI


struct ContentView: View {
//    @Environment(SpeziOneSec.self) private var speziOneSec
    
    @State private var isShowingSheet1 = false
    
    var body: some View {
        Form {
            Button("Initiate Flow") {
                isShowingSheet1 = true
            }
        }
        .onAppear {
            // swiftlint:disable:next force_try
//            speziOneSec.surveyUrl = try! URL("https://redcap.stanford.edu/surveys/?s=X3LE4CMD9FR4LKN8", strategy: .url)
        }
//        .sheet(isPresented: $isShowingSheet1) {
//            SpeziOneSecSheet()
//        }
    }
}
