//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import MediaPlayer
import Nimble

final class PlayerMetadataTests: TestCase {
    private static func value(for identifier: AVMetadataIdentifier, in items: [AVMetadataItem]) async throws -> Any? {
        guard let item = AVMetadataItem.metadataItems(from: items, filteredByIdentifier: identifier).first else { return nil }
        return try await item.load(.value)
    }

    func testNowPlayingInfo() {
        let metadata = PlayerMetadata(
            title: "title",
            subtitle: "subtitle",
            imageSource: .image(.init(systemName: "circle")!)
        )
        let nowPlayingInfo = metadata.nowPlayingInfo
        expect(nowPlayingInfo[MPMediaItemPropertyTitle] as? String).to(equal("title"))
        expect(nowPlayingInfo[MPMediaItemPropertyArtist] as? String).to(equal("subtitle"))
        expect(nowPlayingInfo[MPMediaItemPropertyArtwork]).notTo(beNil())
    }

    func testExternalMetadata() async {
        let metadata = PlayerMetadata(
            identifier: "identifier",
            title: "title",
            subtitle: "subtitle",
            description: "description",
            imageSource: .image(.init(systemName: "circle")!),
            episodeInformation: .long(season: 2, episode: 3)
        )
        let externalMetadata = metadata.externalMetadata
        await expect {
            try await Self.value(for: .commonIdentifierAssetIdentifier, in: externalMetadata) as? String
        }.to(equal("identifier"))
        await expect {
            try await Self.value(for: .commonIdentifierTitle, in: externalMetadata) as? String
        }.to(equal("title"))
        await expect {
            try await Self.value(for: .iTunesMetadataTrackSubTitle, in: externalMetadata) as? String
        }.to(equal("subtitle"))
        await expect {
            try await Self.value(for: .commonIdentifierDescription, in: externalMetadata) as? String
        }.to(equal("description"))
        await expect {
            try await Self.value(for: .quickTimeUserDataCreationDate, in: externalMetadata) as? String
        }.to(equal("S2, E3"))

        await expect {
            try await Self.value(for: .commonIdentifierArtwork, in: externalMetadata)
        }
#if os(tvOS)
        .notTo(beNil())
#else
        .to(beNil())
#endif
    }
}
