//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import AVFoundation
import Player
import SwiftUI

/// A standalone player view with standard controls.
/// Behavior: h-exp, v-exp
struct PlayerView: View {
    let media: Media
    @StateObject private var player = Player(configuration: .standard)

    var body: some View {
        PlaybackView(player: player)
            .onAppear(perform: load)
            .tracked(title: "player")
    }

    private func load() {
        player.append(media.playerItem())
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
