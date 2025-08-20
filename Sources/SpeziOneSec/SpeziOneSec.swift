//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation
public import Observation
public import Spezi
public import SpeziHealthKit
private import SpeziHealthKitBulkExport
internal import SpeziLocalStorage


/// The SpeziOneSec module.
@Observable
@MainActor
@available(iOS 17.0, *)
public final class SpeziOneSec: Module, EnvironmentAccessible, Sendable {
    public enum State: Int, Hashable, Codable, Sendable {
        /// The Spezi one sec integration is, for whatever reason, not available.
        case unavailable
        /// The Spezi one sec integration is available, but hasn't yet been initiated.
        case available
        /// The Spezi one sec integration is currently being initiated.
        case initiating
        /// The Spezi one sec integration is currently active.
        case active
        /// The Spezi one sec integration has been completed.
        case completed
    }
    
    public struct HealthExportConfiguration: Hashable, Sendable {
        let destination: URL
        let sampleTypes: SampleTypesCollection
        let timeRange: Range<Date>
        
        /// - parameter destination: Directory to which the Health export files should be written.
        public init(destination: URL, sampleTypes: SampleTypesCollection, timeRange: Range<Date>) {
            self.destination = destination
            self.sampleTypes = sampleTypes
            self.timeRange = timeRange
        }
    }
    
    @ObservationIgnored @StandardActor var standard: any SpeziOneSecConstraint
    @ObservationIgnored @Application(\.logger) var logger
    @ObservationIgnored @Dependency(HealthKit.self) private var healthKit
    @ObservationIgnored @Dependency(BulkHealthExporter.self) private var bulkExporter
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    
    nonisolated private let healthExportConfig: HealthExportConfiguration
    nonisolated(unsafe) private let fileManager = FileManager.default
    
    public internal(set) var state: State = .unavailable {
        didSet {
            try? localStorage.store(state, for: .speziOneSecState)
        }
    }
    
    /// The URL of the survey the user should fill out in order to enroll in the study.
    ///
    /// This URL should be constructed by the app, based on the survey and the token obtained from REDCap.
    public var surveyUrl: URL?
    
    /// Creates a new instance of the `SpeziOneSec` module
    public nonisolated init(healthExportConfig: HealthExportConfiguration) {
        self.healthExportConfig = healthExportConfig
    }
    
    public func configure() {
        state = (try? localStorage.load(.speziOneSecState)) ?? .available
        Task {
            do {
                if try localStorage.load(.didInitiateBulkExport) == true {
                    // we've initiated the Health Export at some point in the past.
                    // we now check if it has completed, and, if not, tell it to continue.
                    let session = try await healthExportSession()
                    if session.state != .completed {
                        try await initiateBulkExport()
                    }
                }
            } catch {
                logger.error("\(error)")
            }
        }
    }
}


// MARK: HealthKit Data Collection

@available(iOS 17.0, *)
extension SpeziOneSec {
    func initiateBulkExport() async throws {
        if !fileManager.itemExists(at: healthExportConfig.destination) {
            try fileManager.createDirectory(at: healthExportConfig.destination, withIntermediateDirectories: true)
        }
        try await healthKit.askForAuthorization(for: .init(read: healthExportConfig.sampleTypes))
        let session = try await healthExportSession()
        _ = try session.start(retryFailedBatches: true)
    }
    
    
    /// Obtains the bulk health export session.
    private func healthExportSession() async throws -> some BulkExportSession<HKSampleToFHIRProcessor> {
        try await bulkExporter.session(
            withId: .speziOneSec,
            for: healthExportConfig.sampleTypes,
            startDate: .absolute(healthExportConfig.timeRange.lowerBound),
            endDate: healthExportConfig.timeRange.upperBound,
            batchSize: .automatic,
            using: HKSampleToFHIRProcessor(outputDirectory: healthExportConfig.destination)
        )
    }
}


// MARK: Utils

extension BulkExportSessionIdentifier {
    fileprivate static let speziOneSec = Self("edu.stanford.SpeziOneSec")
}

@available(iOS 17.0, *)
extension LocalStorageKeys {
    fileprivate static let speziOneSecState = LocalStorageKey<SpeziOneSec.State>("edu.stanford.SpeziOneSec.state")
    fileprivate static let didInitiateBulkExport = LocalStorageKey<Bool>("edu.stanford.SpeziOneSec.didInitiateBulkExport")
}
