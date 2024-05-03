//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct Metadata: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: "🍎", subtitle: "🍏", imageSource: .image(.init(named: "apple")!))
    }
}

struct IntegratingWithControlCenter: View {
    @StateObject private var player = Player(item: .simple(
        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
        metadata: Metadata()
    ))

    var body: some View {
        ZStack {
            VideoView(player: player)
        }
        .onAppear {
            player.play()
            player.becomeActive()
        }
    }
}
