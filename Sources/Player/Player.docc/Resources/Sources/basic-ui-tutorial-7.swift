import Player
import SwiftUI

private struct PlayerView: View {
    @StateObject private var player = Player(item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!))
    @State private var state: PlaybackState = .idle

    var body: some View {
        ZStack {
            VideoView(player: player)
            Button(action: player.togglePlayPause) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .onReceive(player: player, assign: \.playbackState, to: $state)
        .background(.black)
        .ignoresSafeArea()
    }
}
