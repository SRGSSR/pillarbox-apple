//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct LinkView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @StateObject private var isBusyTracker = PropertyTracker(keyPath: \.isBusy)
    @State private var isDisplayed = true

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                BasicPlaybackView(player: isDisplayed ? player : Player())
                ProgressView()
                    .opacity(isBusyTracker.value ? 1 : 0)
            }
            Toggle("Content displayed", isOn: $isDisplayed)
                .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onAppear(perform: play)
        .onForeground(perform: resume)
        .bind(isBusyTracker, to: player)
        .tracked(name: "link")
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }

    private func resume() {
        player.play()
    }
}

#Preview {
    LinkView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
