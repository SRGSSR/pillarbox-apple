//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct ControlsView: View {
    @ObservedObject var player: Player
    let progressTracker: ProgressTracker
    let skipTracker: SkipTracker

    var body: some View {
        HStack(spacing: 30) {
            SkipBackwardButton(player: player, progressTracker: progressTracker, skipTracker: skipTracker)
            PlaybackButton(player: player)
            SkipForwardButton(player: player, progressTracker: progressTracker, skipTracker: skipTracker)
        }
        .animation(.defaultLinear, value: player.playbackState)
    }
}
