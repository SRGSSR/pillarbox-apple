//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemStatePublisherTests: XCTestCase {
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()

    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [.unknown],
            from: player.itemStatePublisher(),
            during: 2
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .readyToPlay],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: player.itemStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testUnavailableStream() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [
                .unknown,
                .failed(error: NSError(
                    domain: URLError.errorDomain,
                    code: URLError.fileDoesNotExist.rawValue,
                    userInfo: [
                        NSLocalizedDescriptionKey: "The requested URL was not found on this server."
                    ]
                ))
            ],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: Stream.corruptOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [.unknown, .failed(error: EnumError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testResourceLoadingFailure() {
        let asset = AVURLAsset(url: Stream.custom.url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global())
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [.unknown, .failed(error: EnumError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }
}
