//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Player
import SwiftUI

private enum ActivePlayer {
    case top
    case bottom
}

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var topPlayer = Player(configuration: .externalPlaybackDisabled)
    @StateObject private var bottomPlayer = Player(configuration: .externalPlaybackDisabled)
    @State private var activePlayer = ActivePlayer.top

    var body: some View {
        VStack(spacing: 10) {
            Group {
                BasicPlaybackView(player: topPlayer)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        activePlayer = .top
                    }
                    .saturation(activePlayer == .top ? 1 : 0)
                BasicPlaybackView(player: bottomPlayer)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        activePlayer = .bottom
                    }
                    .saturation(activePlayer == .bottom ? 1 : 0)
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
}

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView(
            media1: Media(from: URNTemplate.onDemandHorizontalVideo),
            media2: Media(from: URNTemplate.onDemandVerticalVideo)
        )
    }
}
