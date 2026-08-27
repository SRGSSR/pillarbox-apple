//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import AVFoundation

/// The configuration applied to a download.
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct DownloadConfiguration: Equatable, Codable {
    /// The default configuration.
    public static let `default` = Self()

    /// The maximum preferred bitrate.
    ///
    /// Disabled when set to zero.
    public var preferredPeakBitRate: Double

    /// The preferred maximum video resolution.
    ///
    /// Disabled when set to `.zero`.
    public var preferredMaximumResolution: CGSize {
        get {
            .init(width: preferredMaximumResolutionWidth, height: preferredMaximumResolutionHeight)
        }
        set {
            preferredMaximumResolutionWidth = newValue.width
            preferredMaximumResolutionHeight = newValue.height
        }
    }

    private var preferredMaximumResolutionWidth: CGFloat
    private var preferredMaximumResolutionHeight: CGFloat
    private var mediaSelectionPreferences: [String: DownloadMediaSelectionPreference] = [:]

    /// Creates a configuration.
    ///
    /// - Parameters:
    ///   - preferredPeakBitRate: The maximum preferred bitrate.
    ///   - preferredMaximumResolution: The preferred maximum video resolution.
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

    /// Sets the media selection preference for the given characteristic.
    ///
    /// - Parameters:
    ///   - preference: The media selection preference.
    ///   - characteristic: The characteristic.
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

#endif
