//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LiveRadioToggleView: View {
    @StateObject private var model = LiveRadioToggleViewModel()

    var body: some View {
        VStack(spacing: 0) {
            modePicker()
            _PlaybackView(player: model.player, model: model)
            playlistView()
        }
        .onAppear(perform: model.play)
    }

    private func modePicker() -> some View {
        Picker("Mode", selection: $model.mode) {
            ForEach(LiveRadioToggleMode.allCases) { mode in
                Text(mode.rawValue)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    private func playlistView() -> some View {
        List(model.medias, id: \.self, selection: $model.currentMedia) { media in
            Text(media.title)
        }
    }
}

private struct _PlaybackView: View {
    @ObservedObject var player: Player
    @ObservedObject var model: LiveRadioToggleViewModel
    @State private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                audioVideoView()
                playbackButton()
            }
            Slider(progressTracker: progressTracker)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .bind(progressTracker, to: player)
    }

    @ViewBuilder
    private func audioVideoView() -> some View {
        switch model.mode {
        case .audio:
            artworkView()
        case .video:
            videoView()
        }
    }

    private func videoView() -> some View {
        VideoView(player: player)
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
        ZStack {
            Color.clear
            LazyImage(source: player.metadata.imageSource) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .animation(.easeIn(duration: 0.2), value: player.metadata.imageSource)
    }
}

extension LiveRadioToggleView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    LiveRadioToggleView()
}
