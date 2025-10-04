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
    typealias ShouldNavigate = @MainActor (URLRequest) async -> Bool
    typealias DidNavigate = @MainActor (WebViewProxy) async -> Void
    
    fileprivate struct Config: Sendable {
        let initialUrl: URL
        let shouldNavigate: ShouldNavigate
        let didNavigate: DidNavigate
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
    /// The estimated progress of the current navigation operation, if applicable. Otherwise `nil`.
    @Binding private var currentProgress: Double?
    
    var body: some View {
        WebViewImpl(
            config: config,
            currentUrl: $currentUrl,
            currentProgress: $currentProgress,
            onAlert: { message in
                assert(alert == nil, "Already presenting an alert!") // Q: is this smth we need to worry about (stacked alerts...)
                await withCheckedContinuation { continuation in
                    alert = .init(message: message, continuation: continuation)
                }
            },
            onConfirm: { message in
                assert(confirmation == nil, "Already presenting an alert!") // Q: is this smth we need to worry about (stacked alerts...)
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
        .alert(
            currentUrl?.host() ?? "",
            isPresented: Binding<Bool> {
                self.confirmation != nil
            } set: { newValue in
                // Note that we intentionally ignore `newValue == true` in here!
                if !newValue {
                    self.alert = nil
                }
            },
            presenting: confirmation
        ) { config in
            let cancelImp = {
                config.continuation.resume(returning: false)
                self.confirmation = nil
            }
            let confirmImp = {
                config.continuation.resume(returning: true)
                self.confirmation = nil
            }
            #if compiler(>=6.2)
            if #available(iOS 26, *) {
                Button("Cancel", role: .cancel, action: cancelImp)
                    .keyboardShortcut(.cancelAction)
                Button("OK", role: .confirm, action: confirmImp)
                    .keyboardShortcut(.defaultAction)
            } else {
                Button("Cancel", role: .cancel, action: cancelImp)
                    .keyboardShortcut(.cancelAction)
                Button("OK", action: confirmImp)
                    .keyboardShortcut(.defaultAction)
            }
            #else
            Button("Cancel", role: .cancel, action: cancelImp)
                .keyboardShortcut(.cancelAction)
            Button("OK", action: confirmImp)
                .keyboardShortcut(.defaultAction)
            #endif
        } message: { config in
            Text(config.message)
        }
    }
    
    init(
        url: URL,
        currentProgress: Binding<Double?> = .constant(nil),
        shouldNavigate: @escaping ShouldNavigate,
        didNavigate: @escaping DidNavigate
    ) {
        config = .init(initialUrl: url, shouldNavigate: shouldNavigate, didNavigate: didNavigate)
        _currentProgress = currentProgress
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
    @Binding private var currentProgress: Double?
    private let onAlert: @MainActor (String) async -> Void
    private let onConfirm: @MainActor (String) async -> Bool
    
    init(
        config: WebView.Config,
        currentUrl: Binding<URL?>,
        currentProgress: Binding<Double?>,
        onAlert: @MainActor @escaping (String) async -> Void,
        onConfirm: @MainActor @escaping (String) async -> Bool,
    ) {
        self.config = config
        _currentUrl = currentUrl
        _currentProgress = currentProgress
        self.onAlert = onAlert
        self.onConfirm = onConfirm
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let coordinator = context.coordinator
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        coordinator.kvoObservations.append(webView.observe(\.estimatedProgress, options: [.new]) { [weak coordinator] _, change in
            guard let coordinator else {
                return
            }
            MainActor.assumeIsolated {
                currentProgress = coordinator.isNavigating ? change.newValue : nil
            }
        })
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
        var kvoObservations: [NSKeyValueObservation] = []
        private(set) var isNavigating = false
        
        init(parent: WebViewImpl) {
            self.parent = parent
        }
        
        // MARK: WKNavigationDelegate
        
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            switch await parent.config.shouldNavigate(navigationAction.request) {
            case true:
                navigationAction.shouldPerformDownload ? .download : .allow
            case false:
                .cancel
            }
        }
        
        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation! // swiftlint:disable:this implicitly_unwrapped_optional
        ) {
            isNavigating = true
            parent.currentProgress = 0
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // swiftlint:disable:this implicitly_unwrapped_optional
            parent.currentUrl = webView.url
            isNavigating = false
            parent.currentProgress = nil
            Task {
                await parent.config.didNavigate(WebViewProxy(webView))
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
