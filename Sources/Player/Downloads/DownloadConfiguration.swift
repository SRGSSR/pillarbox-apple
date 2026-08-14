//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import AVFoundation

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct DownloadConfiguration: Codable {
    public static let `default` = Self()

    public var preferredPeakBitRate: Double

    private var auxiliaryMediaSelectionPreferences: [String: DownloadMediaSelectionPreference] = [:]

    public init(preferredPeakBitRate: Double = 0) {
        self.preferredPeakBitRate = preferredPeakBitRate
    }

    mutating func setAuxiliaryMediaSelectionPreference(_ preference: DownloadMediaSelectionPreference, for characteristic: AVMediaCharacteristic) {
        auxiliaryMediaSelectionPreferences[characteristic.rawValue] = preference
    }

    func apply(to configuration: AVAssetDownloadConfiguration, with configurator: MediaSelectionConfigurator?) {
        configuration.primaryContentConfiguration.variantQualifiers = [
            AVAssetVariantQualifier(predicate: NSPredicate(format: "peakBitRate <= \(preferredPeakBitRate)"))
        ]

        // TODO: Test implementation. Must be rewritten.
        if let configurator {
            let audibleSelections = configurator.mediaSelections(withLanguages: ["en", "fr-FR", "de", "es", "it"], for: .audible)
            let legibleSelections = configurator.mediaSelections(withLanguages: ["fr-FR", "de"], for: .legible)
            configuration.primaryContentConfiguration.mediaSelections = audibleSelections + legibleSelections
        }
    }
}

#endif

// swiftlint:enable missing_docs
