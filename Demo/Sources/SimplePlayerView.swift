//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player()

    var body: some View {
        ZStack {
            VideoView(player: player)
            ProgressView()
                .opacity(player.isBuffering ? 1 : 0)
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

struct SimplePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
