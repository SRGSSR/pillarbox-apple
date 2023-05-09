//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import AVFoundation
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)

    var body: some View {
        ZStack {
            VideoView(player: player)
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
        }
        .onAppear(perform: play)
        .tracked(title: "Simple")
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
