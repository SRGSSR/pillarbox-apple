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

    private func mediaSelections(with configurator: MediaSelectionConfigurator?) -> [AVMediaSelection] {
        guard let configurator else { return [] }
        return mediaSelectionPreferences.flatMap { characteristic, preference -> [AVMediaSelection]  in
            switch preference.kind {
            case .automatic:
                return []
            case let .on(languages: languages):
                return configurator.mediaSelections(withLanguages: languages, for: AVMediaCharacteristic(characteristic))
            }
        }
    }

    public mutating func setMediaSelectionPreference(_ preference: DownloadMediaSelectionPreference, for characteristic: AVMediaCharacteristic) {
        mediaSelectionPreferences[characteristic.rawValue] = preference
    }

    func apply(to configuration: AVAssetDownloadConfiguration, with configurator: MediaSelectionConfigurator?) {
        configuration.primaryContentConfiguration.variantQualifiers = [
            AVAssetVariantQualifier(predicate: NSPredicate(format: "peakBitRate <= \(preferredPeakBitRate)"))
        ]
        configuration.primaryContentConfiguration.mediaSelections = mediaSelections(with: configurator)
    }
}

#endif

// swiftlint:enable missing_docs
