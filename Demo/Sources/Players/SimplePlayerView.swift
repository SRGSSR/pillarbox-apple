//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import AVFoundation
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)

    var body: some View {
        ZStack {
            VideoView(player: player)
            progressView()
            playbackButton()
        }
        .onAppear(perform: play)
        .tracked(name: "simple-player")
    }

    @ViewBuilder
    private func progressView() -> some View {
        ProgressView()
            .opacity(player.isBusy ? 1 : 0)
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
                .opacity(player.isBusy ? 0 : 1)
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

struct SimplePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
