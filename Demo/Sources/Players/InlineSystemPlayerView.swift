//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct InlineSystemPlayerView: View {
    private static let model = PlayerViewModel()

    private var padding: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone ? 50 : 200
    }

    var body: some View {
        SystemVideoView(player: Self.model.player, isPictureInPictureSupported: true)
            .ignoresSafeArea()
            .enabledForInAppPictureInPictureWithCleanup {
                Self.model.media = nil
            }
            .tracked(name: "inline-system-player")
            .aspectRatio(16 / 9, contentMode: .fit)
            .padding(padding)
    }

    init(media: Media) {
        Self.model.media = media
    }
}
