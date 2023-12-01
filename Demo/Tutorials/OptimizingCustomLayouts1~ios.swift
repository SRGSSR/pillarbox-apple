//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import Player
import SwiftUI

struct OptimizingCustomLayouts1: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        VideoView(player: player)
            ._debugBodyCounter()
            .overlay(alignment: .bottom) {
                ProgressSlider(player: player)
            }
            .onAppear(perform: player.play)
    }
}

private struct ProgressSlider: View {
    let player: Player

    @StateObject private var progressTracker = ProgressTracker(
        interval: .init(value: 1, timescale: 10)
    )

    var body: some View {
        Slider(progressTracker: progressTracker)
            ._debugBodyCounter(color: .blue)
            .padding()
            .bind(progressTracker, to: player)
    }
}
