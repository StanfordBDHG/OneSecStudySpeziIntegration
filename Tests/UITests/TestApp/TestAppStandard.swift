//
// This source file is part of the SpeziOneSec open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit
import SpeziOneSec
import SwiftUI


actor TestAppStandard: Standard {
}


extension TestAppStandard: HealthKitConstraint {
    func handleNewSamples<Sample>(_ addedSamples: some Collection<Sample>, ofType sampleType: SampleType<Sample>) async {}
    func handleDeletedObjects<Sample>(_ deletedObjects: some Collection<HKDeletedObject>, ofType sampleType: SampleType<Sample>) async {}
}


extension TestAppStandard: SpeziOneSecConstraint {
    func userRequestedUnenrollment() async throws {
        // ???
    }
}
