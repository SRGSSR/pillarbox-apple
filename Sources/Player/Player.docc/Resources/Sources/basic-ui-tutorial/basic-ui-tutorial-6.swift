import Player
import SwiftUI

struct ContentView: View {
    private let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    @StateObject private var player = Player(item: .simple(url: url))
    @State private var state: PlaybackState = .idle

    var body: some View {
        ZStack {
            VideoView(player: player)
            Button(action: player.togglePlayPause) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .onReceive(player: player, assign: \.playbackState, to: $state)
    }
}
