//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct PictureInPictureView: View {
    @ObservedObject var player: Player

    var body: some View {
        VStack(spacing: 0) {
            playbackView()
            playbackView()
        }
        .background(.black)
        .onAppear {
            play()
        }
    }
}

extension PictureInPictureView {
    @ViewBuilder
    private func playbackView() -> some View {
        ZStack {
            VideoView(player: player)
            playbackButton()
        }
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
        }
    }

    private func play() {
        player.append(.youTube(videoId: "ApM_KEr1ktQ"))
        player.play()
    }
}

#Preview {
    PictureInPictureView(player: Player())
}
