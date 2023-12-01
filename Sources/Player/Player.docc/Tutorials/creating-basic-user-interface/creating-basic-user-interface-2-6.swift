import Player
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!),
        configuration: .init(backwardSkipInterval: 5, forwardSkipInterval: 15)
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
            HStack(spacing: 20) {
                Button(action: { player.skipBackward() }) {
                    Image(systemName: "gobackward.5")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                }
                Button(action: player.togglePlayPause) {
                    Image(systemName: player.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                }
                Button(action: { player.skipForward() }) {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                }
            }
        }
    }
}
