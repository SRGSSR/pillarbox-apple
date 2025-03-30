import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        GeometryReader { geometry in
            VideoView(player: player)
                .gesture(skipGesture(in: geometry))
        }
        .ignoresSafeArea()
        .onAppear(perform: player.play)
    }

    private func skipGesture(in geometry: GeometryProxy) -> some Gesture {
        SpatialTapGesture()
    }
}
