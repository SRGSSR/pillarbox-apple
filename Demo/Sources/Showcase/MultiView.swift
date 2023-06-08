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

/// Behavior: h-exp, v-exp
private struct SingleView: View {
    @ObservedObject var player: Player
    let action: () -> Void

    var body: some View {
        ZStack {
            VideoView(player: player)
                .accessibilityAddTraits(.isButton)
                .onTapGesture(perform: action)
            routePickerView(player: player)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
        }
    }

    @ViewBuilder
    private func routePickerView(player: Player) -> some View {
        if player.configuration.allowsExternalPlayback {
            RoutePickerView()
                .tint(.white)
                .frame(width: 45, height: 45)
        }
    }
}

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var topPlayer = Player()
    @StateObject private var bottomPlayer = Player()
    @State private var activePosition: PlayerPosition = .top

    var body: some View {
        VStack(spacing: 10) {
            Group {
                playerView(player: topPlayer, position: .top)
                playerView(player: bottomPlayer, position: .bottom)
            }
            .background(.black)
        }
        .onChange(of: activePosition) { position in
            setActive(position: position)
        }
        .onAppear {
            Self.play(media: media1, in: topPlayer)
            Self.play(media: media2, in: bottomPlayer)
            setActive(position: activePosition)
        }
        .tracked(title: "multi")
    }

    private static func play(media: Media, in player: Player) {
        player.append(media.playerItem())
        player.play()
    }

    @ViewBuilder
    private func playerView(player: Player, position: PlayerPosition) -> some View {
        SingleView(player: player) { activePosition = position }
            .accessibilityAddTraits(.isButton)
            .saturation(activePosition == position ? 1 : 0)
    }

    private func setActive(position: PlayerPosition) {
        switch position {
        case .top:
            topPlayer.isMuted = false
            bottomPlayer.isMuted = true
            topPlayer.becomeActiveIfPossible()
        case .bottom:
            topPlayer.isMuted = true
            bottomPlayer.isMuted = false
            bottomPlayer.becomeActiveIfPossible()
        }
    }
}

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView(
            media1: Media(from: URNTemplate.onDemandHorizontalVideo),
            media2: Media(from: URNTemplate.onDemandVideo)
        )
    }
}
