//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SystemPlayerView: View {
    let media: Media

    @StateObject private var player = Player()

    var body: some View {
        SystemVideoView(player: player)
            .ignoresSafeArea()
            .onAppear {
                play()
            }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

struct SystemPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
