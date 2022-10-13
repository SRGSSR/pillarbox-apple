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

struct BasicPlayerView: View {
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
        guard let item = media.playerItem else { return }
        player.append(item)
        player.play()
    }
}

// MARK: Preview

struct BasicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        BasicPlayerView(media: MediaURL.onDemandVideoLocalHLS)
    }
}
