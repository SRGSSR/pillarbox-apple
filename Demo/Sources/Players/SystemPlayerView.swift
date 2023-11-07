//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

private final class PlayerViewModel {
    var media: Media? {
        didSet {
            guard media != oldValue else { return }
            if let playerItem = media?.playerItem() {
                player.items = [playerItem]
            }
            else {
                player.removeAllItems()
            }
        }
    }

    let player = Player(configuration: .standard)
}

// Behavior: h-exp, v-exp
struct SystemPlayerView: View {
    private static let model = PlayerViewModel()

    var body: some View {
        SystemVideoView(player: Self.model.player, isPictureInPictureSupported: true)
            .ignoresSafeArea()
            .enabledForInAppPictureInPictureWithCleanup {
                Self.model.media = nil
            }
            .tracked(name: "system-player")
    }

    init(media: Media) {
        Self.model.media = media
    }
}

#Preview {
    SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
