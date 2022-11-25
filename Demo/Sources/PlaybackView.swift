//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Player
import SwiftUI
import UserInterface

// MARK: View

// Behavior: h-exp, v-hug
private struct TimeSlider: View {
    @ObservedObject var player: Player
    @StateObject var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 10))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
    }
}

// Behavior: h-exp, v-exp
struct PlaybackView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            VideoView(player: player)
            TimeSlider(player: player)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            if player.isBuffering {
                ProgressView()
            }
        }
    }
}

// MARK: Preview

struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackView(player: Player())
            .background(.black)
            .previewLayout(.fixed(width: 320, height: 180))
    }
}
