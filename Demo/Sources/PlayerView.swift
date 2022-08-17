//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: Player

    private var playbackButtonImageName: String {
        switch player.state {
        case .playing:
            return "pause.circle.fill"
        default:
            return "play.circle.fill"
        }
    }

    var body: some View {
        ZStack {
            VideoView(player: player)
            Color(white: 0, opacity: 0.3)
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: playbackButtonImageName)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .tint(.white)
            }
        }
    }
}
