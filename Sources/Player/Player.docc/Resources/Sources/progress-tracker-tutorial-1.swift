import Player
import SwiftUI

struct ProgressTrackerTutorial: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        VideoView(player: player)
            .onAppear(perform: player.play)
    }
}
