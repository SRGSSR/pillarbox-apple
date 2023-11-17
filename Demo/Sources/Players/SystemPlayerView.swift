//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SystemPlayerView: View {
    private static let model = PlayerViewModel()

    var body: some View {
        SystemVideoView(player: Self.model.player, isPictureInPictureSupported: true)
            .ignoresSafeArea()
            .enabledForInAppPictureInPictureWithCleanup {
                Self.model.media = nil
            }
            .onAppear(perform: Self.model.play)
            .tracked(name: "system-player")
    }

    init(media: Media) {
        Self.model.media = media
    }
}

extension SystemPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
