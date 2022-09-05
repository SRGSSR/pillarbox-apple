//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

struct PlayerView: View {
    let url: URL

    @StateObject private var player = Player()

    var body: some View {
        ZStack {
            Group {
                VideoView(player: player)
                ControlsView(player: player)
            }
            .ignoresSafeArea()
#if os(iOS)
            Slider(player: player)
                .tint(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
#endif
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        player.append(AVPlayerItem(url: url))
        player.play()
    }
}

extension PlayerView {
    struct ControlsView: View {
        @ObservedObject var player: Player

        private var playbackButtonImageName: String {
            switch player.playbackState {
            case .playing:
                return "pause.circle.fill"
            default:
                return "play.circle.fill"
            }
        }

        var body: some View {
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

// MARK: Preview

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(url: URL(string: "http://localhost::8123/valid_stream/master.m3u8")!)
    }
}
