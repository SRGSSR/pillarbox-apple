//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Player
import SwiftUI

private enum PlayerPosition {
    case top
    case bottom
}

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var topPlayer = Player(configuration: .externalPlaybackDisabled)
    @StateObject private var bottomPlayer = Player(configuration: .externalPlaybackDisabled)
    @State private var activePosition: PlayerPosition = .top

    var body: some View {
        VStack(spacing: 10) {
            Group {
                playerView(player: topPlayer, position: .top)
                playerView(player: bottomPlayer, position: .bottom)
            }
            .background(.black)
        }
        .onAppear {
            Self.play(media: media1, in: topPlayer)
            Self.play(media: media2, in: bottomPlayer)
        }
        .tracked(title: "multi")
    }

    private static func play(media: Media, in player: Player) {
        player.append(media.playerItem())
        player.play()
    }

    @ViewBuilder
    private func playerView(player: Player, position: PlayerPosition) -> some View {
        BasicPlaybackView(player: player)
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                activePosition = position
            }
            .saturation(activePosition == position ? 1 : 0)
    }
}

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView(
            media1: Media(from: URNTemplate.onDemandHorizontalVideo),
            media2: Media(from: URNTemplate.onDemandVerticalVideo)
        )
    }
}
