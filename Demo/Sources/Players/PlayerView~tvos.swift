//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct PlayerView: View {
    let media: Media
    var supportsPictureInPicture = false
    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    var body: some View {
        PlaybackView(player: model.player)
            .enabledForInAppPictureInPicture(persisting: model)
            .background(.black)
            .onAppear(perform: play)
            .tracked(name: "player")
    }

    init(media: Media) {
        self.media = media
    }

    private func play() {
        model.media = media
        model.play()
    }
}

#Preview {
    PlayerView(media: URLMedia.appleAdvanced_16_9_TS_HLS)
}
