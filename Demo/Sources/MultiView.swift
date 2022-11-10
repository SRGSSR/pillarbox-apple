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

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var topPlayer = Player()
    @StateObject private var bottomPlayer = Player()

    var body: some View {
        VStack {
            Group {
                PlaybackView(player: topPlayer)
                PlaybackView(player: bottomPlayer)
            }
            .background(.black)
        }
        .onAppear {
            Self.play(media: media1, in: topPlayer)
            Self.play(media: media2, in: bottomPlayer)
        }
    }

    private static func play(media: Media, in player: Player) {
        guard let item = media.playerItem else { return }
        player.append(item)
        player.play()
    }
}

// MARK: Preview

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView(
            media1: MediaURL.appleBasic_16_9_TS_HLS,
            media2: MediaURL.appleAdvanced_16_9_HEVC_h264_HLS
        )
    }
}
