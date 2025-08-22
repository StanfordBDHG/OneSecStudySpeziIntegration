//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOneSecInterface
import SwiftUI


struct EnrolledSheet: View {
    private static let stanfordUrl = URL(string: "https://stanford.edu")! // swiftlint:disable:this force_unwrapping
    
    @Environment(SpeziOneSecModule.self) private var speziOneSec
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemName: "party.popper")
                        .animation(.bouncy)
                        .font(.system(size: 150))
                        .accessibilityHidden(true)
                    Text("You're currently enrolled in the [NAME] study.")
                }
                .listRowBackground(Color.clear)
            }
            Section {
                Text("Todo Information about the study, etc")
                Link(destination: Self.stanfordUrl) {
                    HStack {
                        Text("Visit our website")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .accessibilityHidden(true)
                    }
                }
            }
            Section {
//                AsyncButton(role: .destructive, state: $viewState) {
//                    try await speziOneSec.standard.userRequestedUnenrollment()
//                } label: {
//                    Text("UNENROLL_BUTTON_TITLE")
//                        .bold()
//                        .frame(maxWidth: .infinity, minHeight: 38)
//                }
//                .buttonStyle(.borderedProminent)
//                .listRowInsets(EdgeInsets())
            }
        }
    }
}
