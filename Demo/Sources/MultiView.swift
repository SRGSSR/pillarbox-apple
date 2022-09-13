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

struct MultiView: View {
    @StateObject var topPlayer = Player()
    @StateObject var bottomPlayer = Player()

    var body: some View {
        VStack {
            Group {
                VideoView(player: topPlayer)
                VideoView(player: bottomPlayer)
            }
            .background(.black)
        }
        .onAppear {
            Self.play(
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
                in: topPlayer
            )
            Self.play(
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!,
                in: bottomPlayer
            )
        }
    }

    private static func play(url: URL, in player: Player) {
        player.append(AVPlayerItem(url: url))
        player.play()
    }
}

// MARK: Preview

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView()
    }
}
