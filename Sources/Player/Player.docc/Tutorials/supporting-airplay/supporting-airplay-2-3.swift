import PillarboxPlayer
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
            routePicker()
        }
        .onAppear {
            player.becomeActive()
            player.play()
        }
    }

    private func routePicker() -> some View {
        RoutePickerView()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}
