import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
            controls()
        }
        .onAppear(perform: player.play)
    }

    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.6)
                .ignoresSafeArea()
            playbackButton()
        }
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.shouldPlay ? "pause.circle" : "play.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .tint(.white)
        }
    }
}
