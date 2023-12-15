//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SystemPlayerView: View {
    let media: Media
    private static let model = PlayerViewModel()

    var body: some View {
        SystemVideoView(player: Self.model.player, isPictureInPictureSupported: true)
            .ignoresSafeArea()
            .enabledForInAppPictureInPictureWithSetup {
                Self.model.media = media
            } cleanup: {
                Self.model.media = nil
            }
            .onAppear(perform: Self.model.play)
            .tracked(name: "system-player")
    }
}

extension SystemPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
