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

    private var mediaSelectionPreferences: [String: DownloadMediaSelectionPreference] = [:]

    public init(preferredPeakBitRate: Double = 0) {
        self.preferredPeakBitRate = preferredPeakBitRate
    }

    mutating func setMediaSelectionPreference(_ preference: DownloadMediaSelectionPreference, for characteristic: AVMediaCharacteristic) {
        mediaSelectionPreferences[characteristic.rawValue] = preference
    }

    func apply(to configuration: AVAssetDownloadConfiguration, with configurator: MediaSelectionConfigurator?) {
        configuration.primaryContentConfiguration.variantQualifiers = [
            AVAssetVariantQualifier(predicate: NSPredicate(format: "peakBitRate <= \(preferredPeakBitRate)"))
        ]

        // TODO: Test implementation. Must be rewritten.
        if let configurator {
            let audibleSelections = configurator.mediaSelections(withLanguages: ["de", "es", "it"], for: .audible)
            let legibleSelections = configurator.mediaSelections(withLanguages: ["de", "ja"], for: .legible)
            configuration.primaryContentConfiguration.mediaSelections = audibleSelections + legibleSelections
        }
    }
}

#endif

// swiftlint:enable missing_docs
