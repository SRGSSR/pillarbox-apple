//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Player
import SwiftUI

#if os(iOS)
// Behavior: h-exp, v-hug
private struct TimeSlider: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(
        interval: CMTime(value: 1, timescale: 10),
        seekBehavior: UserDefaults.standard.seekBehavior
    )

    var body: some View {
        Slider(progressTracker: progressTracker)
            .bind(progressTracker, to: player)
            ._debugBodyCounter()
    }
}
#endif

/// A playback view with basic controls. Requires an ancestor view to own the player to be used.
/// Behavior: h-exp, v-exp
struct BasicPlaybackView: View {
    @ObservedObject var player: Player
    @StateObject private var isBusyTracker = PropertyTracker(keyPath: \.isBusy)

    var body: some View {
        ZStack {
            VideoView(player: player)
#if os(iOS)
            TimeSlider(player: player)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
#endif
            ProgressView()
                .opacity(isBusyTracker.value ? 1 : 0)
        }
        .bind(isBusyTracker, to: player)
    }
}

#Preview {
    BasicPlaybackView(player: Player())
}
