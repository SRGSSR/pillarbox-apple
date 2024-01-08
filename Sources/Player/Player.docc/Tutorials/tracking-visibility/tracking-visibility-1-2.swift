import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    @StateObject private var visibilityTracker = VisibilityTracker()

    var body: some View {
        ZStack {
            VideoView(player: player)
            controls()
        }
        .onAppear(perform: player.play)
    }

    @ViewBuilder
    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.6)
                .ignoresSafeArea()
            playbackButton()
        }
    }

    @ViewBuilder
    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.isRunning ? "pause.circle" : "play.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .tint(.white)
        }
    }
}
