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

private struct ControlsView: View {
    @ObservedObject var player: Player
    let isUserInterfaceHidden: Bool

    private var playbackButtonImageName: String {
        switch player.playbackState {
        case .playing:
            return "pause.circle.fill"
        default:
            return "play.circle.fill"
        }
    }

    var body: some View {
        ZStack {
            if !isUserInterfaceHidden {
                Color(white: 0, opacity: 0.3)
                if !player.isBuffering {
                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: playbackButtonImageName)
                            .resizable()
                    }
                    .frame(width: 90, height: 90)
                }
            }
            if player.isBuffering {
                ProgressView()
            }
        }
        .tint(.white)
        .animation(.easeInOut(duration: 0.2), value: player.isBuffering)
    }
}

struct PlayerView: View {
    let medias: [Media]

    @StateObject private var player = Player()
    @State private var isUserInterfaceHidden = false

    var body: some View {
        ZStack {
            Group {
                VideoView(player: player)
                ControlsView(player: player, isUserInterfaceHidden: isUserInterfaceHidden)
            }
            .ignoresSafeArea()
#if os(iOS)
            Slider(player: player)
                .tint(.white)
                .opacity(isUserInterfaceHidden ? 0 : 1)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
#endif
        }
        .background(.black)
        .animation(.easeInOut(duration: 0.2), value: isUserInterfaceHidden)
        .onAppear {
            play()
        }
        .onTapGesture {
            isUserInterfaceHidden.toggle()
        }
    }

    init(medias: [Media]) {
        self.medias = medias
    }

    init(media: Media) {
        self.init(medias: [media])
    }

    private func play() {
        medias.compactMap(\.source.playerItem).forEach { item in
            player.append(item)
        }
        player.play()
    }
}

// MARK: Preview

struct PlayerView_Previews: PreviewProvider {
    static let media = Media(
        id: "id",
        title: "Title",
        description: "Description",
        source: .url(Stream.local)
    )

    static var previews: some View {
        PlayerView(media: media)
    }
}
