//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreBusiness
import Player
import SwiftUI
import UserInterface

// MARK: View

struct PlayerView: View {
    let media: Media

    @StateObject private var player = Player()
    @State private var isUserInterfaceHidden = false

    var body: some View {
        ZStack {
            Group {
                VideoView(player: player)
                ControlsView(player: player)
                    .opacity(isUserInterfaceHidden ? 0 : 1)
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
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isUserInterfaceHidden.toggle()
            }
        }
    }

    private func play() {
        switch media.source {
        case let .url(url):
            player.append(AVPlayerItem(url: url))
        case let .urn(urn):
            player.append(AVPlayerItem(urn: urn))
        }
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
    static let media = Media(
        id: "id",
        title: "Title",
        description: "Description",
        source: .url(URL(string: "http://localhost::8123/valid_stream/master.m3u8")!)
    )

    static var previews: some View {
        PlayerView(media: media)
    }
}
