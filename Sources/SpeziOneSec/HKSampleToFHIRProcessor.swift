//
// This source file is part of the My Heart Counts iOS application based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKitOnFHIR
import SpeziFoundation
import SpeziHealthKit
import SpeziHealthKitBulkExport

@available(iOS 17.0, *)
struct HKSampleToFHIRProcessor: BatchProcessor {
    let outputDirectory: URL
    
    func process<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) throws {
        guard !samples.isEmpty else {
            return
        }
        try storeSamples(samples, of: sampleType)
    }
    
    private func storeSamples<Sample>(_ samples: consuming [Sample], of sampleType: SampleType<Sample>) throws {
        let resources = try samples.mapIntoResourceProxies()
        _ = consume samples
        let encoded = try JSONEncoder().encode(resources)
        _ = consume resources
        let compressed = try encoded.compressed(using: Zlib.self)
        _ = consume encoded
        let compressedUrl = outputDirectory.appendingPathComponent("\(sampleType.id)_\(UUID().uuidString).json.zlib")
        try compressed.write(to: compressedUrl)
        _ = consume compressed
    }
}
