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
public struct DownloadConfiguration: Equatable, Codable {
    public static let `default` = Self()

    public var preferredPeakBitRate: Double
    public var preferredMaximumResolution: CGSize

    private var mediaSelectionPreferences: [String: DownloadMediaSelectionPreference] = [:]

    public init(
        preferredPeakBitRate: Double = 0,
        preferredMaximumResolution: CGSize = .zero
    ) {
        self.preferredPeakBitRate = preferredPeakBitRate
        self.preferredMaximumResolution = preferredMaximumResolution
    }

    private func mediaSelections(with configurator: MediaSelectionConfigurator?) -> [AVMediaSelection] {
        guard let configurator else { return [] }
        return mediaSelectionPreferences.flatMap { characteristic, preference -> [AVMediaSelection]  in
            switch preference.kind {
            case .automatic:
                return []
            case let .languages(languages):
                return configurator.mediaSelections(withLanguages: languages, for: AVMediaCharacteristic(characteristic))
            }
        }
    }

    public mutating func setMediaSelectionPreference(_ preference: DownloadMediaSelectionPreference, for characteristic: AVMediaCharacteristic) {
        mediaSelectionPreferences[characteristic.rawValue] = preference
    }

    func apply(to configuration: AVAssetDownloadConfiguration, with configurator: MediaSelectionConfigurator?) {
        configuration.primaryContentConfiguration.variantQualifiers = [
            AVAssetVariantQualifier(
                predicate: NSCompoundPredicate(
                    orPredicateWithSubpredicates: [
                        NSPredicate(format: "peakBitRate < \(preferredPeakBitRate)"),
                        AVAssetVariantQualifier.predicate(forPresentationHeight: preferredMaximumResolution.height, operatorType: .lessThanOrEqualTo),
                        AVAssetVariantQualifier.predicate(forPresentationWidth: preferredMaximumResolution.width, operatorType: .lessThanOrEqualTo)
                    ]
                )
            )
        ]
        configuration.primaryContentConfiguration.mediaSelections = mediaSelections(with: configurator)
    }
}

#endif

// swiftlint:enable missing_docs
