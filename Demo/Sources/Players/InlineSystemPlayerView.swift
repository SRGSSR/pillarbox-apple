//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct InlineSystemPlayerView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    private var padding: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone ? 50 : 200
    }

    var body: some View {
        SystemVideoView(player: model.player)
            .supportsPictureInPicture()
            .enabledForInAppPictureInPicture(persisting: model)
            .ignoresSafeArea()
            .aspectRatio(16 / 9, contentMode: .fit)
            .padding(padding)
            .onAppear(perform: play)
            .tracked(name: "inline-system-player")
    }

    private func play() {
        model.media = media
        model.play()
    }
}

extension InlineSystemPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    InlineSystemPlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_TS_HLS))
}
