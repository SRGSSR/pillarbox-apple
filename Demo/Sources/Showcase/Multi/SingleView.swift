//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

/// Behavior: h-exp, v-exp
struct SingleView: View {
    @ObservedObject var player: Player

    @State private var isBusy = false
    private var isMonoscopic = false
    private var supportsPictureInPicture = false

    var body: some View {
        ZStack {
            videoView(player: player)
            playbackButton(player: player)
            ProgressView()
                .opacity(isBusy ? 1 : 0)
                .accessibilityHidden(true)
        }
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }

    init(player: Player) {
        self.player = player
    }

    @ViewBuilder
    private func videoView(player: Player) -> some View {
        VideoView(player: player)
            .supportsPictureInPicture(supportsPictureInPicture)
            .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func playbackButton(player: Player) -> some View {
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
}

extension SingleView {
    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> SingleView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}
