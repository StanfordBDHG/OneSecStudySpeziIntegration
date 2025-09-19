//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import Spezi
import SpeziOneSecInterface
import SwiftUI


struct StudySurveySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SpeziOneSec.self) private var speziOneSec
    
    @State private var isShowingCancelAlert = false
    @State private var isDone = false
    
    var body: some View {
        if let url = speziOneSec.surveyUrl {
            NavigationStack {
                WebView(url: url) { request in
                    await shouldNavigate(request)
                } didNavigate: { webView in
                    await didNavigate(webView)
                }
                .navigationTitle("Stanford Study")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if !isDone {
                        ToolbarItem(placement: .cancellationAction) {
                            cancelButton
                        }
                    } else {
                        ToolbarItem(placement: .confirmationAction) {
                            confirmButton
                        }
                    }
                }
            }
            .interactiveDismissDisabled()
        } else {
            ContentUnavailableView("MISSING_URL", systemImage: "exclamationmark.triangle")
        }
    }
    
    
    @ViewBuilder private var cancelButton: some View {
        Group {
            let fallbackButton = Button("Cancel", role: .cancel) {
                isShowingCancelAlert = true
            }
            #if compiler(>=6.2)
            if #available(iOS 26, *) {
                Button(role: .cancel) {
                    isShowingCancelAlert = true
                }
            } else {
                fallbackButton
            }
            #else
            fallbackButton
            #endif
        }
        .alert("Cancel Enrollment", isPresented: $isShowingCancelAlert) {
            Button("No", role: .cancel) {
                isShowingCancelAlert = false
            }
            Button("Yes", role: .destructive) {
                dismiss()
            }
        } message: {
            Text(
                """
                Are you sure you want to cancel enrolling in the [TODO STUDY NAME] study?
                You can re-enroll at a later time if you feel like it.
                """
            )
        }
    }
    
    @ViewBuilder private var confirmButton: some View {
        let fallbackButton = Button("Done") {
            dismiss()
        }
        .bold()
        #if compiler(>=6.2)
        if #available(iOS 26, *) {
            Button(role: .confirm) {
                dismiss()
            }
        } else {
            fallbackButton
        }
        #else
        fallbackButton
        #endif
    }
    
    
    private func shouldNavigate(_ request: URLRequest) async -> Bool {
        if request.url?.host() == "one-sec.app" {
            isDone = true
            dismiss()
            return false
        } else {
            return true
        }
    }
    
    private func didNavigate(_ webView: WebViewProxy) async {
        if await webView.pageContainsField(named: "healthkit_export_initiated") {
            await initiateHealthExport()
        } else if await webView.pageContainsElement(withId: "surveyacknowledgment") {
            isDone = true
            speziOneSec.updateState(.active)
        }
    }
    
    private func initiateHealthExport() async {
        do {
            try await speziOneSec.initiateBulkExport()
        } catch {
            // Q how to handle this? (will depend on the specific error. eg for missing permissions we could throw up an alert, etc)
            speziOneSec.logger.error("Error initiating bulk health export: \(error)")
        }
    }
}


extension WebViewProxy {
    func pageContainsField(named variableName: String) async -> Bool {
        (try? await evaluateJavaScript(
            #"document.querySelector('div[data-mlm-field="\#(variableName)"]') !== null"#
        ) as? Bool) == true
    }
    
    func pageContainsElement(withId id: String) async -> Bool {
        (try? await evaluateJavaScript(
            "document.getElementById('\(id)') !== null"
        ) as? Bool) == true
    }
}
