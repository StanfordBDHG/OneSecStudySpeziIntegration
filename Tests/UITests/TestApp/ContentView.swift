//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SpeziOneSecInterface
import SwiftUI


struct ContentView: View {
    var body: some View {
        if #available(iOS 17, *) {
            StudyButton()
        }
    }
}


@available(iOS 17, *)
struct StudyButton: View {
    @Environment(SpeziOneSecModule.self) private var speziOneSec
    @State private var isShowingSheet1 = false
    
    var body: some View {
        Form {
            Button("Initiate Flow") {
                isShowingSheet1 = true
            }
        }
        .onAppear {
            speziOneSec.surveyUrl = try? URL("https://lukaskollmer.s3.amazonaws.com/spezionesectest.html", strategy: .url)
//            speziOneSec.surveyUrl = try? URL("https://redcap.stanford.edu/surveys/?s=X3LE4CMD9FR4LKN8", strategy: .url)
        }
        .sheet(isPresented: $isShowingSheet1) {
            speziOneSec.makeSpeziOneSecSheet()
        }
    }
}
