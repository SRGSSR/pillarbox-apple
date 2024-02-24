//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class TextStyleRulesTests: TestCase {
    private static let textStyleRules = [
        AVTextStyleRule(textMarkupAttributes: [
            kCMTextMarkupAttribute_ForegroundColorARGB: [1, 1, 0, 0],
            kCMTextMarkupAttribute_ItalicStyle: true
        ])
    ]

    func testDefaultWithEmptyPlayer() {
        let player = Player()
        expect(player.textStyleRules).to(beEmpty())
    }

    func testDefaultWithLoadedPlayer() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.textStyleRules).to(beEmpty())
        expect(player.queuePlayer.currentItem?.textStyleRules).to(beEmpty())
    }

    func testStyleUpdate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.textStyleRules = Self.textStyleRules
        expect(player.textStyleRules).to(equal(Self.textStyleRules))
        expect(player.queuePlayer.currentItem?.textStyleRules).to(equal(Self.textStyleRules))
    }

    func testStylePreservedBetweenItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.onDemand.url)
        ])
        player.textStyleRules = Self.textStyleRules
        player.advanceToNextItem()
        expect(player.queuePlayer.currentItem?.textStyleRules).to(equal(Self.textStyleRules))
    }
}
