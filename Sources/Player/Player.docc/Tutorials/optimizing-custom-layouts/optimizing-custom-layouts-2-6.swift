import PillarboxCore
import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        VStack {
            VideoView(player: player)
            BufferingView(player: player)
        }
        ._debugBodyCounter()
        .onAppear(perform: player.play)
    }
}

private struct BufferingView: View {
    let player: Player

    @State private var buffer: Float = 0

    var body: some View {
        ProgressView(value: buffer)
            .padding()
            .onReceive(player: player, assign: \.buffer, to: $buffer)
    }
}
