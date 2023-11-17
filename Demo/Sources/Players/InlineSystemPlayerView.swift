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
            .aspectRatio(16 / 9, contentMode: .fit)
            .padding(padding)
            .onAppear(perform: Self.model.play)
            .tracked(name: "inline-system-player")
    }

    init(media: Media) {
        Self.model.media = media
    }
}

extension InlineSystemPlayerView: SourceCode {
    static var filePath: String { #file }
}

#Preview {
    InlineSystemPlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_TS_HLS))
}
