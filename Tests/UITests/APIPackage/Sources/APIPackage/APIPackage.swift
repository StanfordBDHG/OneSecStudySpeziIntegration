// The Swift Programming Language
// https://docs.swift.org/swift-book

import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

class Test {
    
    private let client: Client
    
    public init() {
        
        self.client = Client(
            serverURL: URL(string: "https://tips.one-sec.app/api/v1")!,
            configuration: .init(dateTranscoder: .iso8601),
            transport: URLSessionTransport(),
            middlewares: [
            ]
        )
        
    }
    
    public func load() async throws {
        
        let _ = try await client.getTip(path: .init(id: "fjakslfadslfjklas"))
        
    }
    
}
