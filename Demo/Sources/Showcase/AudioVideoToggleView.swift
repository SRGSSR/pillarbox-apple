//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct Stream: Hashable {
    let title: String
    let audio: String
    let video: String
}

private enum Mode: String, Identifiable, CaseIterable {
    case audio = "Audio"
    case video = "Video"

    var id: Self { self }
}

@available(tvOS, unavailable)
struct AudioVideoToggleView: View {
    private static let streams: [Stream] = [
        .init(title: "SRF1", audio: "urn:srf:audio:69e8ac16-4327-4af4-b873-fd5cd6e895a7", video: "urn:srf:video:5b90d1fb-477b-4d98-86a6-82921a4bb0ea"),
        .init(title: "SRF3", audio: "urn:srf:audio:dd0fa1ba-4ff6-4e1a-ab74-d7e49057d96f", video: "urn:srf:video:972b2dbd-3958-43b7-8c15-e92f56c8d734"),
        // swiftlint:disable:next line_length
        .init(title: "SRF Musikwelle", audio: "urn:srf:audio:a9c5c070-8899-46c7-ac27-f04f1be902fd", video: "urn:srf:video:973440d3-60a5-4ddf-ae83-2c77815a32a1"),
        .init(title: "SRF Virus", audio: "urn:srf:audio:66815fe2-9008-4853-80a5-f9caaffdf3a9", video: "urn:srf:video:2a60b590-8a28-4540-bce8-fc4e52b3b5d8"),
        .init(title: "RTS Couleur3", audio: "urn:rts:audio:3262363", video: "urn:rts:video:8841634")
    ]

    @StateObject private var player = Player()
    @State private var mode: Mode = .audio
    @State private var streamType: StreamType = .unknown
    @State private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        VStack(spacing: 0) {
            playbackModeView()
            playbackView()
            playlistView()
        }
        .onAppear {
            player.items = Self.streams.map { .urn($0.audio) }
            player.play()
        }
        .onChange(of: mode, perform: switchTo)
        .bind(progressTracker, to: player)
        .onReceive(player: player, assign: \.streamType, to: $streamType)
    }

    private func switchTo(_ mode: Mode) {
        if let currentItem = player.currentItem, let currentIndex = player.items.firstIndex(of: currentItem) {
            let position = player.time()
            player.items = Self.streams.map { .urn($0.video) }
            if let playerItem = player.items[safeIndex: currentIndex] {
                player.resume(at(position), in: playerItem)
            }
        }
    }

    private func playbackModeView() -> some View {
        Picker("Playback Mode", selection: $mode) {
            ForEach(Mode.allCases) { mode in
                Text(mode.rawValue)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    private func playbackView() -> some View {
        VStack(spacing: 0) {
            ZStack {
                audioVideoView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                playbackButton()
            }
            Slider(progressTracker: progressTracker)
                .opacity(streamType == .unknown ? 0 : 1)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }

    @ViewBuilder
    private func audioVideoView() -> some View {
        switch mode {
        case .audio:
            artworkView()
        case .video:
            videoView()
        }
    }

    private func videoView() -> some View {
        VideoView(player: player)
    }

    private func playlistView() -> some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { $item in
            if let index = player.items.firstIndex(of: item) {
                Text(Self.streams[safeIndex: index]?.title ?? "")
            }
        }
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.shouldPlay ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
        }
    }

    private func artworkView() -> some View {
        LazyImage(source: player.metadata.imageSource) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .animation(.easeIn(duration: 0.2), value: player.metadata.imageSource)
    }
}

#if os(iOS)
extension AudioVideoToggleView: SourceCodeViewable {
    static let filePath = #file
}
#endif
