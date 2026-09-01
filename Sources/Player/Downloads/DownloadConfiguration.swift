//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import AVFoundation

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct DownloadConfiguration: Equatable, Codable {
    public static let `default` = Self()

    public var preferredPeakBitRate: Double
    public var preferredMaximumResolutionWidth: CGFloat
    public var preferredMaximumResolutionHeight: CGFloat

    private var mediaSelectionPreferences: [String: DownloadMediaSelectionPreference] = [:]

    public init(
        preferredPeakBitRate: Double = 0,
        preferredMaximumResolution: CGSize = .zero
    ) {
        self.preferredPeakBitRate = preferredPeakBitRate
        self.preferredMaximumResolutionWidth = preferredMaximumResolution.width
        self.preferredMaximumResolutionHeight = preferredMaximumResolution.height
    }

    private func mediaSelections(from selection: AVMediaSelection, using provider: MediaSelectionProvider) -> [AVMediaSelection] {
        mediaSelectionPreferences.flatMap { characteristic, preference -> [AVMediaSelection] in
            switch preference.kind {
            case .automatic:
                return []
            case let .languages(languages):
                guard let configurator = mediaSelectionConfigurator(for: .init(characteristic), using: provider) else { return [] }
                return configurator.mediaSelections(from: selection, withLanguages: languages)
            case .all:
                guard let configurator = mediaSelectionConfigurator(for: .init(characteristic), using: provider) else { return [] }
                return configurator.allMediaSelections(from: selection)
            }
        }
    }

    private func mediaSelectionConfigurator(for characteristic: AVMediaCharacteristic, using provider: MediaSelectionProvider) -> MediaSelectionConfigurator? {
        switch characteristic {
        case .audible:
            return AudibleMediaSelectionConfigurator(provider: provider)
        case .legible:
            return LegibleMediaSelectionConfigurator(provider: provider)
        default:
            return nil
        }
    }

    public mutating func setMediaSelectionPreference(_ preference: DownloadMediaSelectionPreference, for characteristic: AVMediaCharacteristic) {
        mediaSelectionPreferences[characteristic.rawValue] = preference
    }

    func apply(selection: AVMediaSelection?, to configuration: AVAssetDownloadConfiguration, using provider: MediaSelectionProvider) {
        let resolutionPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            AVAssetVariantQualifier.predicate(forPresentationWidth: preferredMaximumResolutionWidth, operatorType: .lessThanOrEqualTo),
            AVAssetVariantQualifier.predicate(forPresentationHeight: preferredMaximumResolutionHeight, operatorType: .lessThanOrEqualTo)
        ])
        let peakBitRatePredicate = NSPredicate(format: "peakBitRate <= \(preferredPeakBitRate)")
        configuration.primaryContentConfiguration.variantQualifiers = [
            AVAssetVariantQualifier(predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [resolutionPredicate, peakBitRatePredicate]))
        ]
        if let selection {
            configuration.primaryContentConfiguration.mediaSelections = mediaSelections(from: selection, using: provider)
        }
        configuration.auxiliaryContentConfigurations = []
    }
}

// swiftlint:enable missing_docs
