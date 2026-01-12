//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LiveLabel: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @State private var streamType: StreamType = .unknown

    private var canSkipToLive: Bool {
        player.canSkipToDefault()
    }

    private var liveButtonColor: Color {
        canSkipToLive && streamType == .dvr ? .gray : .red
    }

    var body: some View {
        Group {
            if streamType == .dvr || streamType == .live {
                Text("LIVE")
                    .font(.footnote)
                    .padding(.horizontal, 7)
                    .background(liveButtonColor)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
        }
        .onReceive(player: player, assign: \.streamType, to: $streamType)
    }
}
