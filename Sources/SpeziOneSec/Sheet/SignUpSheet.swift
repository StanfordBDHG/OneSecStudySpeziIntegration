//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

private import Spezi
import SpeziOneSecInterface
import SwiftUI
private import WebKit


struct SignUpSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SpeziOneSec.self) private var speziOneSec
    
    @State private var isShowingCancelAlert = false
    @State private var isDone = false
    
    var body: some View {
        if let url = speziOneSec.surveyUrl {
            NavigationStack {
                WebView(url: url, isDone: $isDone) {
                    await initiateHealthExport()
                }
                .navigationTitle("STUDY_NAME")
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
    
    private func initiateHealthExport() async {
        do {
            try await speziOneSec.initiateBulkExport()
        } catch {
            // Q how to handle this? (will depend on the specific error. eg for missing permissions we could throw up an alert, etc)
            speziOneSec.logger.error("Error initiating bulk health export: \(error)")
        }
    }
}


private struct WebView: UIViewRepresentable {
    @Environment(SpeziOneSec.self) private var speziOneSec
    let url: URL
    @Binding var isDone: Bool
    let initiateHealthExport: @MainActor () async -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        #if DEBUG
        webView.isInspectable = true
        #endif
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }
}


extension WebView {
    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // swiftlint:disable:this implicitly_unwrapped_optional
            Task {
                if try await webView.evaluateJavaScript(
                    #"document.querySelector('div[data-mlm-field="healthkit_export_trigger"]') !== null"#
                ) as? Bool == true {
                    await parent.initiateHealthExport()
                } else if try await webView.evaluateJavaScript(
                    "document.getElementById('surveyacknowledgment') !== null"
                ) as? Bool == true {
                    parent.isDone = true
                    parent.speziOneSec.updateState(.active)
                }
            }
        }
    }
}
