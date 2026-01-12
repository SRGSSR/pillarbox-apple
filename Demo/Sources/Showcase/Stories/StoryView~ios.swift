//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct StoryView: View {
    @ObservedObject var player: Player
    @State private var isBusy = false

    var body: some View {
        ZStack {
            VideoView(player: player)
                .gravity(.resizeAspectFill)
                .ignoresSafeArea()
            ProgressView()
                .opacity(isBusy ? 1 : 0)
            TimeProgress(player: player)
        }
        .tint(.white)
        .animation(.defaultLinear, value: isBusy)
        .accessibilityElement()
        .accessibilityLabel("Video")
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }
}

#Preview {
    StoryView(player: Player(item: URLMedia.appleAdvanced_16_9_TS_HLS.item()))
}
