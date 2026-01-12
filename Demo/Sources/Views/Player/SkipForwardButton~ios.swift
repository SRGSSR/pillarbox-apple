//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SkipForwardButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var skipTracker: SkipTracker

    var body: some View {
        Button(action: skipForward) {
            Image.goForward(withInterval: player.configuration.forwardSkipInterval)
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 45)
        .opacity(player.canSkipForward() && !skipTracker.isSkipping ? 1 : 0)
        .animation(.defaultLinear, value: player.canSkipForward())
        .keyboardShortcut("d", modifiers: [])
        .hoverEffect()
        ._debugBodyCounter(color: .green)
    }

    private func skipForward() {
        player.skipForward()
    }
}
