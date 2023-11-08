//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

/// A standalone player view with standard controls.
/// Behavior: h-exp, v-exp
struct PlayerView: View {
    private static let model = PlayerViewModel()

    var body: some View {
        PlaybackView(player: Self.model.player, isPictureInPictureSupported: true)
            .enabledForInAppPictureInPictureWithCleanup {
                Self.model.media = nil
            }
            .onAppear(perform: Self.model.play)
            .tracked(name: "player")
    }

    init(media: Media) {
        Self.model.media = media
    }
}

#Preview {
    PlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
