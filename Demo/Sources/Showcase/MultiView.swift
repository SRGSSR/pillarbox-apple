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
            videoView(player: player)
            playbackButton(player: player)
            routePickerView(player: player)
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
        }
    }

    @ViewBuilder
    private func videoView(player: Player) -> some View {
        VideoView(player: player)
            .accessibilityAddTraits(.isButton)
            .onTapGesture(perform: action)
    }

    @ViewBuilder
    private func playbackButton(player: Player) -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
                .opacity(player.isBusy ? 0 : 1)
        }
    }

    @ViewBuilder
    private func routePickerView(player: Player) -> some View {
        if player.configuration.allowsExternalPlayback {
            RoutePickerView()
                .tint(.white)
                .frame(width: 45, height: 45)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onChange(of: activePosition) { position in
            setActive(position: position)
        }
        .onAppear {
            Self.play(media: media1, in: topPlayer)
            Self.play(media: media2, in: bottomPlayer)
            setActive(position: activePosition)
        }
        .tracked(name: "multi")
    }

    private static func play(media: Media, in player: Player) {
        player.append(media.playerItem())
        player.play()
    }

    private static func make(activePlayer: Player, inactivePlayer: Player) {
        activePlayer.becomeActive()
        activePlayer.isTrackingEnabled = true
        activePlayer.isMuted = false

        inactivePlayer.isTrackingEnabled = false
        inactivePlayer.isMuted = true
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
            Self.make(activePlayer: topPlayer, inactivePlayer: bottomPlayer)
        case .bottom:
            Self.make(activePlayer: bottomPlayer, inactivePlayer: topPlayer)
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
