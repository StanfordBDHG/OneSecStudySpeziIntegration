//
// This source file is part of the OneSecStudySpeziIntegration open source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

@_spi(Spezi) @_spi(APISupport) import Spezi
private import SpeziHealthKit
private import SpeziHealthKitBulkExport
private import SpeziLocalStorage
@_spi(APISupport) import SpeziOneSecInterface
import SwiftUI
import UIKit


/// The SpeziOneSec module.
@Observable
@MainActor
@objc(SpeziOneSec)
final class SpeziOneSec: SpeziOneSecModule, Module, EnvironmentAccessible, Sendable {
    private static var appDelegate: SpeziOneSecAppDelegate? // swiftlint:disable:this weak_delegate
    
    override class var speziInjectionViewModifier: any ViewModifier {
        struct SpeziOneSecInjectionModifier: ViewModifier {
            let spezi: Spezi
            func body(content: Content) -> some View {
                if let speziOneSec = spezi.modules.lazy.compactMap({ $0 as? SpeziOneSec }).first {
                    // SwiftUI's Environment mechanism seems to be using the static type of the parameter passed to `.environment()`,
                    // we need to inject the module a second time (the first time being the automatic injection by Spezi,
                    // as a result of the module's conformance to EnvironmentAccessible), and we need to explicitly specify the
                    // static type as that of our base class.
                    content.environment(speziOneSec as SpeziOneSecModule)
                } else {
                    content
                }
            }
        }
        guard let spezi = SpeziAppDelegate.spezi else {
            preconditionFailure("\(#function) accessed before 'initialize' was called!")
        }
        return SpeziViewModifier(spezi).concat(SpeziOneSecInjectionModifier(spezi: spezi))
    }
    
    @ObservationIgnored @Application(\.logger) var logger
    @ObservationIgnored @Dependency(HealthKit.self) private var healthKit
    @ObservationIgnored @Dependency(BulkHealthExporter.self) private var bulkExporter
    @ObservationIgnored @Dependency(LocalStorage.self) private var localStorage
    
    nonisolated private let healthExportConfig: HealthExportConfiguration
    nonisolated(unsafe) private let fileManager = FileManager.default
    
    /// Creates a new instance of the `SpeziOneSec` module
    nonisolated init(healthExportConfig: HealthExportConfiguration) {
        self.healthExportConfig = healthExportConfig
    }
    
    override class func initialize(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?, // swiftlint:disable:this discouraged_optional_collection
        healthExportConfig: HealthExportConfiguration
    ) {
        let appDelegate = SpeziOneSecAppDelegate(healthExportConfig: healthExportConfig)
        _ = appDelegate.application(application, willFinishLaunchingWithOptions: launchOptions)
        self.appDelegate = appDelegate
    }
    
    func configure() {
        updateState((try? localStorage.load(.speziOneSecState)) ?? .available)
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
    
    override func updateState(_ newState: SpeziOneSecModule.State) {
        super.updateState(newState)
        guard newState != state else {
            return
        }
        try? localStorage.store(newState, for: .speziOneSecState)
    }
    
    override func makeSpeziOneSecSheet() -> AnyView {
        AnyView(SpeziOneSecSheet())
    }
}


// MARK: HealthKit Data Collection

extension SpeziOneSec {
    func initiateBulkExport() async throws {
        if !fileManager.itemExists(at: healthExportConfig.destination) {
            try fileManager.createDirectory(at: healthExportConfig.destination, withIntermediateDirectories: true)
        }
        try await healthKit.askForAuthorization(for: .init(read: healthExportConfig.sampleTypes))
        let session = try await healthExportSession()
        let stream = try session.start(retryFailedBatches: true)
        didStartHealthExport?(AnyAsyncSequence(stream.compactMap(\.self)))
    }
    
    
    /// Obtains the bulk health export session.
    private func healthExportSession() async throws -> some BulkExportSession<HKSampleToFHIRProcessor> {
        try await bulkExporter.session(
            withId: .speziOneSec,
            for: SampleTypesCollection(healthExportConfig.sampleTypes.compactMap { $0.sampleType }),
            startDate: .absolute(healthExportConfig.timeRange.lowerBound),
            endDate: healthExportConfig.timeRange.upperBound,
            batchSize: .automatic,
            using: HKSampleToFHIRProcessor(outputDirectory: healthExportConfig.destination)
        )
    }
}


// MARK: App Delegate and Standard

private final class SpeziOneSecAppDelegate: SpeziAppDelegate {
    private let healthExportConfig: HealthExportConfiguration
    
    override var configuration: Configuration {
        Configuration(standard: SpeziOneSecStandard()) {
            HealthKit()
            BulkHealthExporter()
            SpeziOneSec(healthExportConfig: healthExportConfig)
        }
    }
    
    init(healthExportConfig: HealthExportConfiguration) {
        self.healthExportConfig = healthExportConfig
    }
}


private actor SpeziOneSecStandard: Standard, HealthKitConstraint {
    func handleNewSamples<Sample>(_ addedSamples: some Collection<Sample>, ofType sampleType: SampleType<Sample>) async {}
    func handleDeletedObjects<Sample>(_ deletedObjects: some Collection<HKDeletedObject>, ofType sampleType: SampleType<Sample>) async {}
}


// MARK: Utils

extension BulkExportSessionIdentifier {
    fileprivate static let speziOneSec = Self("edu.stanford.SpeziOneSec")
}

extension LocalStorageKeys {
    fileprivate static let speziOneSecState = LocalStorageKey<SpeziOneSec.State>("edu.stanford.SpeziOneSec.state")
    fileprivate static let didInitiateBulkExport = LocalStorageKey<Bool>("edu.stanford.SpeziOneSec.didInitiateBulkExport")
}
