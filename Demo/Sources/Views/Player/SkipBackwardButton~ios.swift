//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SkipBackwardButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var skipTracker: SkipTracker

    var body: some View {
        Button(action: skipBackward) {
            Image.goBackward(withInterval: player.configuration.backwardSkipInterval)
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 45)
        .opacity(player.canSkipBackward() && !skipTracker.isSkipping ? 1 : 0)
        .animation(.defaultLinear, value: player.canSkipBackward())
        .keyboardShortcut("s", modifiers: [])
        .hoverEffect()
        ._debugBodyCounter(color: .green)
    }

    private func skipBackward() {
        player.skipBackward()
    }
}
