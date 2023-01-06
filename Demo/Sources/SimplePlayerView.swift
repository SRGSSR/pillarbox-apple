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
struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player()

    var body: some View {
        ZStack {
            VideoView(player: player)
            if player.isBuffering {
                ProgressView()
            }
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

// MARK: Preview

struct SimplestPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePlayerView(media: URLTemplate.onDemandVideoLocalHLS.media())
    }
}
