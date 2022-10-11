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

    var body: some View {
        ZStack {
            if !isUserInterfaceHidden {
                Color(white: 0, opacity: 0.3)
                HStack(spacing: 40) {
                    PreviousButton(player: player)
                    PlaybackButton(player: player)
                    NextButton(player: player)
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

private struct NextButton: View {
    @ObservedObject var player: Player

    var body: some View {
        Group {
            if player.canAdvanceToNextItem() {
                Button(action: { player.advanceToNextItem() }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                }
            }
            else {
                Color.clear
            }
        }
        .frame(width: 45, height: 45)
    }
}

private struct PlaybackButton: View {
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
        Button(action: { player.togglePlayPause() }) {
            Image(systemName: playbackButtonImageName)
                .resizable()
        }
        .opacity(player.isBuffering ? 0 : 1)
        .frame(width: 90, height: 90)
    }
}

private struct PreviousButton: View {
    @ObservedObject var player: Player

    var body: some View {
        Group {
            if player.canReturnToPreviousItem() {
                Button(action: { player.returnToPreviousItem() }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                }
            }
            else {
                Color.clear
            }
        }
        .frame(width: 45, height: 45)
    }
}

struct PlayerView: View {
    let medias: [Media]
    let buffered: Bool

    @StateObject private var player = Player()
    @State private var isUserInterfaceHidden = false

    var body: some View {
        ZStack {
            Group {
                VideoView(player: player)
                ControlsView(player: player, isUserInterfaceHidden: isUserInterfaceHidden)
            }
            .onTapGesture {
                isUserInterfaceHidden.toggle()
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
    }

    init(medias: [Media], buffered: Bool = true) {
        self.medias = medias
        self.buffered = buffered
    }

    init(media: Media, buffered: Bool = true) {
        self.init(medias: [media], buffered: buffered)
    }

    private func play() {
        medias.compactMap(\.source.playerItem).forEach { item in
            if !buffered {
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
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
