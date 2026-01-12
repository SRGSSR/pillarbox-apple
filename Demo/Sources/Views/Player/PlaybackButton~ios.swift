//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct PlaybackButton: View {
    @ObservedObject var player: Player

    private var imageName: String {
        if player.canReplay() {
            return "arrow.counterclockwise.circle.fill"
        }
        else if player.shouldPlay {
            return "pause.circle.fill"
        }
        else {
            return "play.circle.fill"
        }
    }

    private var accessibilityLabel: String {
        if player.canReplay() {
            return "Restart"
        }
        else if player.shouldPlay {
            return "Pause"
        }
        else {
            return "Play"
        }
    }

    var body: some View {
        Button(action: play) {
            Image(systemName: imageName)
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(minWidth: 120, maxHeight: 90)
        .accessibilityLabel(accessibilityLabel)
        .keyboardShortcut(.space, modifiers: [])
        .hoverEffect()
    }

    private func play() {
        if player.canReplay() {
            player.replay()
        }
        else {
            player.togglePlayPause()
        }
    }
}
