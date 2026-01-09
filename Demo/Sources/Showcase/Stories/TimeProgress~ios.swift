//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

struct TimeProgress: View {
    let player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 10))

    var body: some View {
        ProgressView(value: progressTracker.progress)
            .padding()
            .opacity(progressTracker.isProgressAvailable ? 1 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .bind(progressTracker, to: player)
    }
}

#Preview {
    TimeProgress(player: Player(item: URLMedia.appleAdvanced_16_9_TS_HLS.item()))
}
