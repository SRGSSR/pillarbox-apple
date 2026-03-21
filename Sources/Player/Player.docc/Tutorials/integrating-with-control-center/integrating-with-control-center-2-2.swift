import PillarboxPlayer
import SwiftUI

private struct Metadata: PlayerMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: "🍎", subtitle: "🍏", imageSource: .image(.init(named: "apple")!))
    }
}

struct ContentView: View {
    @StateObject private var player = Player(item: .simple(
        url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
        metadata: Metadata()
    ))

    var body: some View {
        VideoView(player: player)
            .onAppear {
                player.play()
                player.becomeActive()
            }
    }
}
