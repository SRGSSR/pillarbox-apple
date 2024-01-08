//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

// Behavior: h-exp, v-exp
struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isBusy = false

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
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
        .tracked(name: "simple-player")
    }

    @ViewBuilder
    private func progressView() -> some View {
        ProgressView()
            .opacity(isBusy ? 1 : 0)
    }

    @ViewBuilder
    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.isRunning ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
                .opacity(isBusy ? 0 : 1)
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

extension SimplePlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    SimplePlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
