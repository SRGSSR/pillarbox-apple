//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var topPlayer = Player()
    @StateObject private var bottomPlayer = Player()

    var body: some View {
        VStack(spacing: 10) {
            Group {
                BasicPlaybackView(player: topPlayer)
                BasicPlaybackView(player: bottomPlayer)
            }
            .background(.black)
        }
        .onAppear {
            Self.play(media: media1, in: topPlayer)
            Self.play(media: media2, in: bottomPlayer)
        }
    }

    private static func play(media: Media, in player: Player) {
        player.append(media.playerItem())
        player.play()
    }
}

// MARK: Preview

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView(
            media1: URLTemplate.appleBasic_16_9_TS_HLS.media(),
            media2: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS.media()
        )
    }
}
