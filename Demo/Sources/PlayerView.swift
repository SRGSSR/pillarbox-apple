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
struct PlayerView: View {
    private let medias: [Media]
    @StateObject private var player = Player()

    var body: some View {
        PlaybackView(player: player)
            .onAppear {
                load()
            }
    }

    init(medias: [Media]) {
        self.medias = medias
    }

    init(media: Media) {
        self.init(medias: [media])
    }

    private func load() {
        player.items = medias.map { $0.playerItem() }
    }
}

// MARK: Preview

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(media: URLTemplate.onDemandVideoLocalHLS.media())
    }
}
