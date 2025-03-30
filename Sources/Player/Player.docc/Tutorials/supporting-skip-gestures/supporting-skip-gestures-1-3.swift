import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    @StateObject private var skipTracker = SkipTracker()

    var body: some View {
        GeometryReader { geometry in
            VideoView(player: player)
                .gesture(skipGesture(in: geometry))
        }
        .ignoresSafeArea()
        .onAppear(perform: player.play)
        .bind(skipTracker, to: player)
    }

    private func skipGesture(in geometry: GeometryProxy) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                if value.location.x < geometry.size.width / 2 {
                    skipTracker.requestSkipBackward()
                }
                else {
                    skipTracker.requestSkipForward()
                }
            }
    }
}
