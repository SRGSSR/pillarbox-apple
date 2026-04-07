import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
            metadata: .init(title: "🍎", subtitle: "🍏", imageSource: .image(.init(named: "apple")!))
        )
    )

    var body: some View {
        VideoView(player: player)
            .onAppear {
                player.play()
                player.becomeActive()
            }
    }
}
