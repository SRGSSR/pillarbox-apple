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
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    var body: some View {
        PlaybackView(player: model.player)
            .supportsPictureInPicture()
            .enabledForInAppPictureInPicture(persisting: model)
            .onAppear(perform: play)
            .tracked(name: "player")
    }

    private func play() {
        model.media = media
        model.play()
    }
}

#Preview {
    PlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
