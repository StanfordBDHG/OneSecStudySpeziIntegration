//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

//import BridgeInterface
//@_spi(Spezi) @_spi(APISupport) private import Spezi
//private import SpeziFoundation
//private import SpeziHealthKit
//private import SpeziHealthKitBulkExport
//private import SpeziOneSec
//import SwiftUI
//import UIKit
//
//
//final class PrincipalClass: BridgeInterfaceProtocol {
//    private static var delegate: SpeziAppDelegate? // swiftlint:disable:this weak_delegate
//    
//    @MainActor static var speziInjectionViewModifier: some ViewModifier {
//        guard let spezi = SpeziAppDelegate.spezi else {
//            preconditionFailure("\(#function) accessed before 'initialize' was called!")
//        }
//        return SpeziViewModifier(spezi)
//    }
//    
//    @MainActor
//    static func initialize(
//        application: UIApplication,
//        launchOptions: [UIApplication.LaunchOptionsKey: Any]? // swiftlint:disable:this discouraged_optional_collection
//    ) {
//        let delegate = AppDelegate()
//        _ = delegate.application(application, willFinishLaunchingWithOptions: launchOptions)
//        self.delegate = delegate
//    }
//}
//
//
//private final class AppDelegate: SpeziAppDelegate {
//    override var configuration: Configuration {
//        Configuration(standard: TestAppStandard()) {
//            HealthKit()
//            BulkHealthExporter()
//            SpeziOneSec(healthExportConfig: .init(
//                destination: .documentsDirectory.appending(path: "healthExport"),
//                sampleTypes: [SampleType.stepCount],
//                timeRange: Calendar.current.rangeOfMonth(for: .now)
//            ))
//        }
//    }
//}
//
//
//private actor TestAppStandard: Standard {}
//
//extension TestAppStandard: HealthKitConstraint {
//    func handleNewSamples<Sample>(_ addedSamples: some Collection<Sample>, ofType sampleType: SampleType<Sample>) async {}
//    func handleDeletedObjects<Sample>(_ deletedObjects: some Collection<HKDeletedObject>, ofType sampleType: SampleType<Sample>) async {}
//}
//
//extension TestAppStandard: SpeziOneSecConstraint {
//    func userRequestedUnenrollment() async throws {
//        // ???
//    }
//}
