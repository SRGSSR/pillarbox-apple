//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// MARK: View

struct PlayerView: View {
    let url: URL
    @StateObject private var player = Player()

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
        .ignoresSafeArea()
        .onAppear {
            play()
        }
    }

    private func play() {
        player.append(AVPlayerItem(url: url))
        player.play()
    }
}

// MARK: Preview

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(url: URL(string: "http://localhost:8000/valid_stream/master.m3u8")!)
    }
}
