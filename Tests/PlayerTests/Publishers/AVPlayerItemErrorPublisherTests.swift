//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxStreams

final class AVPlayerItemErrorPublisherTests: TestCase {
    private static func errorCodePublisher(for item: AVPlayerItem) -> AnyPublisher<URLError.Code, Never> {
        item.errorPublisher()
            .map { .init(rawValue: ($0 as NSError).code) }
            .eraseToAnyPublisher()
    }

    func testNoError() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectNothingPublished(from: item.errorPublisher(), during: .milliseconds(500))
    }

    func testM3u8Error() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [
            URLError.fileDoesNotExist
        ], from: Self.errorCodePublisher(for: item))
    }

    func testMp3Error() {
        let item = AVPlayerItem(url: Stream.unavailableMp3.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [
            URLError.fileDoesNotExist
        ], from: Self.errorCodePublisher(for: item))
    }
}
