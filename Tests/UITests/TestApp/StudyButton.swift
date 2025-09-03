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
struct StudyButton: View {
    @Environment(SpeziOneSecModule.self) private var speziOneSec
    @State private var isShowingSheet = false
    
    var body: some View {
        Button("Initiate Flow") {
            speziOneSec.surveyUrl = try? URL("https://redcap.stanford.edu/surveys/?s=X3LE4CMD9FR4LKN8", strategy: .url)
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            speziOneSec.makeSpeziOneSecSheet()
        }
    }
}
