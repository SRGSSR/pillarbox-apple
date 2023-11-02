//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

final class PlayerViewModel {
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

    func reset() {
        media = nil
    }
}

/// A standalone player view with standard controls.
/// Behavior: h-exp, v-exp
struct PlayerView: View {
    static let model = PlayerViewModel()

    var body: some View {
        PlaybackView(player: Self.model.player)
            .onAppear(perform: PictureInPicture.shared.stop)
            .registerCleanupForInAppPictureInPicture(perform: Self.model.reset)
            .tracked(name: "player")
    }

    init(media: Media) {
        Self.model.media = media
    }
}

#Preview {
    PlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
