import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
            HStack(spacing: 20) {
                skipBackwardButton()
                playbackButton()
                skipForwardButton()
            }
        }
    }

    private func skipBackwardButton() -> some View {
        Button(action: { player.skipBackward() }) {
            Image(systemName: "gobackward.10")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
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

    private func skipForwardButton() -> some View {
        Button(action: { player.skipForward() }) {
            Image(systemName: "goforward.10")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        }
    }
}
