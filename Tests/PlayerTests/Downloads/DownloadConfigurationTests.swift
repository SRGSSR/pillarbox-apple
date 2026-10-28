//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import AVFoundation
import Combine
import Nimble
import PillarboxStreams

@available(tvOS, unavailable)
final class DownloadConfigurationTests: TestCase {
    private static func legibleLanguageIdentifiersPublisher(for url: URL, configuration: DownloadConfiguration) -> AnyPublisher<[String?], Never> {
        let asset = AVURLAsset(url: url)
        return Publishers.CombineLatest(asset.preferredMediaSelectionPublisher(), asset.mediaSelectionProviderPublisher())
            .map { selection, provider in
                let downloadConfiguration = AVAssetDownloadConfiguration(asset: asset, title: "title")
                configuration.apply(selection: selection, to: downloadConfiguration, using: provider)
                return downloadConfiguration.primaryContentConfiguration.mediaSelections.map { selection in
                    provider.mediaSelectorProvider(for: .legible)?.selectedMediaOption(in: selection)?.languageIdentifier
                }
            }
            .eraseToAnyPublisher()
    }

    func testAutomaticWithoutDefaultLegibleOption() throws {
        let identifiers = try waitForSingleOutput(from: Self.legibleLanguageIdentifiersPublisher(for: Stream.onDemandWithOptions.url, configuration: .default))
        expect(identifiers).to(equal([nil]))
    }

    func testAutomaticWithDefaultLegibleOption() throws {
        let identifiers = try waitForSingleOutput(
            from: Self.legibleLanguageIdentifiersPublisher(
                for: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url,
                configuration: .default
            )
        )
        expect(identifiers).to(equal(["en"]))
    }

    func testLegibleLanguagesWithDefaultLegibleOption() throws {
        var configuration = DownloadConfiguration()
        configuration.setMediaSelectionPreference(.languages("fr"), for: .legible)
        let identifiers = try waitForSingleOutput(
            from: Self.legibleLanguageIdentifiersPublisher(
                for: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url,
                configuration: configuration
            )
        )
        expect(identifiers).to(equal(["en", "fr"]))
    }

    func testAllLegibleWithDefaultLegibleOption() throws {
        var configuration = DownloadConfiguration()
        configuration.setMediaSelectionPreference(.all, for: .legible)
        let identifiers = try waitForSingleOutput(
            from: Self.legibleLanguageIdentifiersPublisher(
                for: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url,
                configuration: configuration
            )
        )
        expect(identifiers.first).to(equal("en"))
        expect(identifiers.dropFirst().compactMap(\.self).sorted()).to(equal(["en", "es", "fr", "ja"]))
    }
}
