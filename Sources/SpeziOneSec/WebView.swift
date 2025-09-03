//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SwiftUI
private import WebKit


struct WebView: View {
    fileprivate struct Config: Sendable {
        let initialUrl: URL
        let onNavigation: @MainActor (WebViewProxy) async -> Void
    }
    
    fileprivate struct AlertConfig: Sendable {
        let message: String
        let continuation: CheckedContinuation<Void, Never>
    }
    
    fileprivate struct ConfirmationConfig: Sendable {
        let message: String
        let continuation: CheckedContinuation<Bool, Never>
    }
    
    private let config: Config
    @State private var currentUrl: URL?
    @State private var alert: AlertConfig?
    @State private var confirmation: ConfirmationConfig?
    
    var body: some View {
        WebViewImpl(
            config: config,
            currentUrl: $currentUrl,
            onAlert: { message in
                precondition(alert == nil, "Already presenting an alert!") // Q: is this smth we need to worry about (stacked alerts...)
                await withCheckedContinuation { continuation in
                    alert = .init(message: message, continuation: continuation)
                }
            },
            onConfirm: { message in
                precondition(confirmation == nil, "Already presenting an alert!") // Q: is this smth we need to worry about (stacked alerts...)
                return await withCheckedContinuation { continuation in
                    confirmation = .init(message: message, continuation: continuation)
                }
            }
        )
        .alert(
            currentUrl?.host() ?? "",
            isPresented: Binding<Bool> {
                self.alert != nil
            } set: { newValue in
                // Note that we intentionally ignore `newValue == true` in here!
                if !newValue {
                    self.alert = nil
                }
            },
            presenting: alert
        ) { config in
            Button("OK") {
                config.continuation.resume()
                self.alert = nil
            }
        } message: { config in
            Text(config.message)
        }
        .confirmationDialog(
            currentUrl?.host() ?? "",
            isPresented: Binding<Bool> {
                self.confirmation != nil
            } set: { newValue in
                // Note that we intentionally ignore `newValue == true` in here!
                if !newValue {
                    self.alert = nil
                }
            },
            titleVisibility: .visible,
            presenting: confirmation
        ) { config in
            // TODO iOS 26 buttons here!!! // swiftlint:disable:this todo
            Button("Cancel", role: .cancel) {
                config.continuation.resume(returning: false)
                self.confirmation = nil
            }
            Button("OK") {
                config.continuation.resume(returning: true)
                self.confirmation = nil
            }
            .bold()
        } message: { config in
            Text(config.message)
        }
    }
    
    init(url: URL, onNavigation: @MainActor @escaping (WebViewProxy) async -> Void) {
        config = .init(initialUrl: url, onNavigation: onNavigation)
    }
}


@MainActor
struct WebViewProxy: Sendable {
    private let wkWebView: WKWebView
    
    var url: URL? {
        wkWebView.url
    }
    
    fileprivate init(_ wkWebView: WKWebView) {
        self.wkWebView = wkWebView
    }
    
    func evaluateJavaScript(_ script: String) async throws -> Any? {
        try await wkWebView.evaluateJavaScript(script)
    }
}


// MARK: WebViewImpl

private struct WebViewImpl: UIViewRepresentable {
    private let config: WebView.Config
    @Binding private var currentUrl: URL?
    private let onAlert: @MainActor (String) async -> Void
    private let onConfirm: @MainActor (String) async -> Bool
    
    init(
        config: WebView.Config,
        currentUrl: Binding<URL?>,
        onAlert: @MainActor @escaping (String) async -> Void,
        onConfirm: @MainActor @escaping (String) async -> Bool,
    ) {
        self.config = config
        _currentUrl = currentUrl
        self.onAlert = onAlert
        self.onConfirm = onConfirm
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: config.initialUrl))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }
}


extension WebViewImpl {
    @MainActor
    fileprivate final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewImpl
        
        init(parent: WebViewImpl) {
            self.parent = parent
        }
        
        // MARK: WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // swiftlint:disable:this implicitly_unwrapped_optional
            parent.currentUrl = webView.url
            Task {
                await parent.config.onNavigation(WebViewProxy(webView))
            }
        }
        
        // MARK: WKUIDelegate
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
            await parent.onAlert(message)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async -> Bool {
            await parent.onConfirm(message)
        }
    }
}
