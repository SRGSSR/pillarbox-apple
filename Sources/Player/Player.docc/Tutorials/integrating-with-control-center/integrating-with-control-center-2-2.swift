import PillarboxPlayer
import SwiftUI

private struct Metadata: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: "🍎", subtitle: "🍏", image: .apple)
    }
}

struct ContentView: View {
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
