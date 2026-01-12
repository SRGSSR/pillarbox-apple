//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

struct TimeBar: View {
    @ObservedObject var player: Player
    @ObservedObject var visibilityTracker: VisibilityTracker
    @Binding var isInteracting: Bool

    @StateObject private var progressTracker = ProgressTracker(
        interval: CMTime(value: 1, timescale: 10),
        seekBehavior: UserDefaults.standard.seekBehavior
    )

    var body: some View {
        TimeSlider(player: player, progressTracker: progressTracker, visibilityTracker: visibilityTracker)
            .onChange(of: progressTracker.isInteracting) { isInteracting = $0 }
            .bind(progressTracker, to: player)
    }
}
