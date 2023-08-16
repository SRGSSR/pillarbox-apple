//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import MediaAccessibility
import Nimble
import Streams
import XCTest

private enum MediaAccessibilityDisplayType {
    case automatic
    case disabled
    case enabled(languageCode: String)
}

final class MediaSelectionTests: TestCase {
    private static func setupMediaAccessibilityType(_ type: MediaAccessibilityDisplayType) {
        switch type {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
        case .disabled:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
        case let .enabled(languageCode: languageCode):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
        }
    }

    private static func selectedMediaOption(
        forMediaCharacteristic characteristic: AVMediaCharacteristic,
        player: Player
    ) async throws -> AVMediaSelectionOption? {
        guard let item = player.queuePlayer.currentItem,
              let group = try await item.asset.loadMediaSelectionGroup(for: characteristic) else {
            return nil
        }
        return item.currentMediaSelection.selectedMediaOption(in: group)
    }

    override func setUp() {
        super.setUp()
        Self.setupMediaAccessibilityType(.disabled)
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenEmpty() async throws {
        let player = Player()
        await expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenAvailable() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .audible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        expect(player.selectedMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenFailed() async throws {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testWithoutCharacteristicsAndOptions() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithoutTracks.url))
        await expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenAdvancingToNextItem() async throws {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithTracks.url),
            .simple(url: Stream.onDemandWithoutTracks.url)
        ])
        await expect(player.mediaSelectionCharacteristics).toEventuallyNot(beEmpty())
        player.advanceToNextItem()
        await expect(player.mediaSelectionCharacteristics).toEventually(beEmpty())
    }

    @MainActor
    func testLegibleOptionsMustNotContainForcedSubtitles() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithForcedSubtitles.url))
        await expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .legible).count).to(equal(6))
    }

    @MainActor
    func testInitiallySelectedEnabledAudibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testInitiallySelectedEnabledLegibleOption() async throws {
        Self.setupMediaAccessibilityType(.enabled(languageCode: "ja"))
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(haveLanguageIdentifier("ja"))
    }

    @MainActor
    func testInitiallySelectedAutomaticLegibleOption() async throws {
        Self.setupMediaAccessibilityType(.automatic)
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testInitiallySelectedOptionWithoutAudibleOptions() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithoutTracks.url))
        await expect(player.selectedMediaOption(for: .audible)).toAlways(equal(.disabled), until: .seconds(2))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testInitiallySelectedOptionWithoutLegibleOptions() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithoutTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toAlways(equal(.disabled), until: .seconds(2))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testInitiallySelectedDisabledLegibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testSelectedAudibleOptionWhenAdvancingToNextItem() async throws {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithTracks.url),
            .simple(url: Stream.onDemandWithoutTracks.url)
        ])
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        player.advanceToNextItem()
        await expect(player.selectedMediaOption(for: .audible)).toEventually(equal(.disabled))
    }

    @MainActor
    func testSelectedLegibleOptionWhenAdvancingToNextItem() async throws {
        Self.setupMediaAccessibilityType(.enabled(languageCode: "fr"))
        let player = Player(items: [
            .simple(url: Stream.onDemandWithTracks.url),
            .simple(url: Stream.onDemandWithoutTracks.url)
        ])
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.advanceToNextItem()
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
    }

    @MainActor
    func testSelectEnabledAudibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testSelectAutomaticAudibleOptionDoesNothing() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testSelectDisabledAudibleOptionDoesNothing() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .disabled, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testSelectEnabledLegibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(haveLanguageIdentifier("ja"))
    }

    @MainActor
    func testSelectAutomaticLegibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testSelectDisabledLegibleOption() async throws {
        Self.setupMediaAccessibilityType(.automatic)
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .disabled, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }
}
