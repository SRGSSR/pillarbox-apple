//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

/// Behavior: h-exp, v-exp
struct SingleView: View {
    @ObservedObject var player: Player

    @State private var isBusy = false
    private var isPictureInPictureSupported = false

    var body: some View {
        ZStack {
            videoView(player: player)
            playbackButton(player: player)
            ProgressView()
                .opacity(isBusy ? 1 : 0)
        }
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }

    init(player: Player) {
        self.player = player
    }

    @ViewBuilder
    private func videoView(player: Player) -> some View {
        VideoView(player: player)
            .supportsPictureInPicture(isPictureInPictureSupported)
            .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func playbackButton(player: Player) -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
                .opacity(isBusy ? 0 : 1)
        }
    }
}

extension SingleView {
    func supportsPictureInPicture(_ isPictureInPictureSupported: Bool = true) -> SingleView {
        var view = self
        view.isPictureInPictureSupported = isPictureInPictureSupported
        return view
    }
}
