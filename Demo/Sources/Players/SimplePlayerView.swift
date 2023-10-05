//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @StateObject private var isBusyTracker = PropertyTracker(at: \.isBusy)

    var body: some View {
        ZStack {
            VideoView(player: player)
            progressView()
            playbackButton()
        }
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onAppear(perform: play)
        .bind(isBusyTracker, to: player)
        .tracked(name: "simple-player")
    }

    @ViewBuilder
    private func progressView() -> some View {
        ProgressView()
            .opacity(isBusyTracker.value ? 1 : 0)
    }

    @ViewBuilder
    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
                .opacity(isBusyTracker.value ? 0 : 1)
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

#Preview {
    SimplePlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
