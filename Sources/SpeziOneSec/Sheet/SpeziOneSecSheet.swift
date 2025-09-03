//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOneSecInterface
import SwiftUI


struct SpeziOneSecSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SpeziOneSecModule.self) private var speziOneSec
    
    @State private var subtitle: String = ""
    @State private var isShowingCancelAlert = false
    
    var body: some View {
        NavigationStack {
            switch speziOneSec.state {
            case .unavailable:
                ContentUnavailableView(
                    "Not Available",
                    image: "exclamationmark.octagon",
                    description: Text("The [TODO NAME?] Study is not available at this time.")
                )
            case .available, .initiating:
                SignUpSheet()
            case .active, .completed:
                EmptyView()
            }
        }
    }
}
