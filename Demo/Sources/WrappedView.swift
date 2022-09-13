//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

@MainActor
struct WrappedView: View {
    @StateObject private var model = WrappedViewModel()

    var body: some View {
        VStack {
            VideoView(player: model.player)
            HStack {
                Button(action: { play() }) {
                    Text("Play")
                }
                Button(action: { stop() }) {
                    Text("Stop")
                }
            }
            .padding()
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        model.player = player
        player.play()
    }

    private func stop() {
        model.player = nil
    }
}

// MARK: Preview

struct WrappedView_Previews: PreviewProvider {
    static var previews: some View {
        WrappedView()
    }
}
