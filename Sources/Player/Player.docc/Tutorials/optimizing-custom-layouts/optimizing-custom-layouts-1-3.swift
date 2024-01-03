import PillarboxCore
import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        VideoView(player: player)
            ._debugBodyCounter()
            .onAppear(perform: player.play)
    }
}

private struct ProgressSlider: View {
    @StateObject private var progressTracker = ProgressTracker(
        interval: .init(value: 1, timescale: 10)
    )

    var body: some View {
        Slider(progressTracker: progressTracker)
            ._debugBodyCounter(color: .blue)
            .padding()
    }
}
