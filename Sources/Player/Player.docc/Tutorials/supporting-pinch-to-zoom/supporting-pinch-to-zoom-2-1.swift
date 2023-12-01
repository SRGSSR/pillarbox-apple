import AVFoundation
import Player
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    @State private var gravity: AVLayerVideoGravity = .resizeAspect

    var body: some View {
        VideoView(player: player, gravity: gravity)
            .padding(50)
            .gesture(magnificationGesture())
            .onAppear(perform: player.play)
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                gravity = scale > 1.0 ? .resizeAspectFill : .resizeAspect
            }
    }
}

