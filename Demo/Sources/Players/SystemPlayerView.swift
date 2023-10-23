//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SystemPlayerView: View {
    let media: Media?
    @StateObject private var player = Player()

    init(media: Media? = nil) {
        self.media = media
    }

    var body: some View {
        SystemPipPlayerView(player: player)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                CloseButton()
            }
            .onAppear(perform: play)
            .tracked(name: "system-player")
    }

    private func play() {
        if let media {
            player.append(media.playerItem())
        }
        player.play()
    }
}

#Preview {
    SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
