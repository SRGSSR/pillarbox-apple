import AVFoundation
import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    @State private var gravity: AVLayerVideoGravity = .resizeAspect

    var body: some View {
        VideoView(player: player)
            .gravity(gravity)
            .onAppear(perform: player.play)
    }
}

