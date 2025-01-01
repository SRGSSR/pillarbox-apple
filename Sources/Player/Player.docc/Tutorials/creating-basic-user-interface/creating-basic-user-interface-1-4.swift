import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
            playbackButton()
        }
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.shouldPlay ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
        }
    }
}
