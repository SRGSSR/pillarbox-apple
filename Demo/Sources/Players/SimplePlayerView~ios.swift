//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SimplePlayerView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isBusy = false

    var body: some View {
        ZStack {
            videoView()
            progressView()
            playbackButton()
        }
        .overlay(alignment: .topLeading) {
            CloseButton(topBarStyle: true)
        }
        .onAppear(perform: play)
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
        .tracked(name: "simple-player")
    }

    private func videoView() -> some View {
        VideoView(player: player)
            .background(.black)
            .ignoresSafeArea()
    }

    private func progressView() -> some View {
        ProgressView()
            .opacity(isBusy ? 1 : 0)
            .accessibilityHidden(true)
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.shouldPlay ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
                .opacity(isBusy ? 0 : 1)
        }
    }

    private func play() {
        player.append(media.item())
        player.play()
    }
}

extension SimplePlayerView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    SimplePlayerView(media: URLMedia.appleAdvanced_16_9_TS_HLS)
}
