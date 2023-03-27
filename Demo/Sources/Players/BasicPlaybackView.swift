//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Player
import SwiftUI

// Behavior: h-exp, v-hug
@available(tvOS, unavailable)
private struct TimeSlider: View {
    @ObservedObject var player: Player
    @StateObject var progressTracker = ProgressTracker(
        interval: CMTime(value: 1, timescale: 10),
        seekBehavior: UserDefaults.standard.seekBehavior
    )

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
            .debugBodyCounter()
    }
}

/// A playback view with basic controls. Requires an ancestor view to own the player to be used.
/// Behavior: h-exp, v-exp
struct BasicPlaybackView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            VideoView(player: player)
#if os(iOS)
            TimeSlider(player: player)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
#endif
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
        }
    }
}

struct BasicPlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        BasicPlaybackView(player: Player())
            .background(.black)
            .previewLayout(.fixed(width: 320, height: 180))
    }
}
