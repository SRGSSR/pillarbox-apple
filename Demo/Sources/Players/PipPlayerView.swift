//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Player
import SRGDataProvider
import SRGDataProviderCombine
import SRGDataProviderModel
import SwiftUI

private final class PipPlayerViewModel: ObservableObject {
    static let shared = PipPlayerViewModel()
    
    let player = Player()

    @Published private var media: Media?
    @Published private(set) var mediaComposition: SRGMediaComposition?

    private init() {
        $media
            .map { media -> AnyPublisher<SRGMediaComposition?, Never> in
                guard let media, case let .urn(urn, _) = media.type else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return SRGDataProvider.current!.mediaComposition(forUrn: urn)
                    .map { $0 }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$mediaComposition)
    }

    func play() {
        player.play()
    }

    func reset() {
        media = nil
        player.removeAllItems()
    }

    func replace(with media: Media) {
        self.media = media
        player.removeAllItems()
        player.append(media.playerItem())
    }
}

struct PipPlayerView: View {
    @ObservedObject private var model = PipPlayerViewModel.shared

    init(media: Media? = nil) {
        if let media {
            model.replace(with: media)
        }
    }

    var body: some View {
        VStack {
            PipPlaybackView()
            PipMetadataView()
        }
        .onAppear(perform: model.play)
        .onDisappear {
            if !PictureInPicture.shared.isPictureInPictureActive {
                model.reset()
            }
        }
    }
}

private struct PipPlaybackView: View {
    @ObservedObject private var player = PipPlayerViewModel.shared.player
    @ObservedObject private var visibilityTracker = VisibilityTracker()

    var body: some View {
        ZStack {
            VideoView(player: player)
                .enabledForPictureInPicture()
                .ignoresSafeArea()
            ControlsView()
                .opacity(visibilityTracker.isUserInterfaceHidden ? 0 : 1)
        }
        .tint(.white)
        .onTapGesture(perform: visibilityTracker.toggle)
        .animation(.linear(duration: 0.2), value: visibilityTracker.isUserInterfaceHidden)
        .bind(visibilityTracker, to: player)
    }
}

private struct PipMetadataView: View {
    @ObservedObject private var model = PipPlayerViewModel.shared

    var body: some View {
        VStack {
            if let mediaComposition = model.mediaComposition {
                Text(mediaComposition.mainChapter.title)
            }
            else {
                Text("No title")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct ControlsView: View {
    @ObservedObject private var player = PipPlayerViewModel.shared.player

    var body: some View {
        ZStack {
            Color(white: 0, opacity: 0.4)
                .ignoresSafeArea()
            Button(action: player.togglePlayPause) {
                Image(systemName: playbackButtonImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 90)
            }
            BottomBar()
        }
    }

    private var playbackButtonImageName: String {
        player.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill"
    }
}

private struct BottomBar: View {
    @ObservedObject private var player = PipPlayerViewModel.shared.player
    @ObservedObject private var pictureInPicture = PictureInPicture.shared
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 10))
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Slider(progressTracker: progressTracker)
            if pictureInPicture.isPictureInPicturePossible {
                Button(action: startPictureInPicture) {
                    Image(systemName: pipImageName)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding()
        .bind(progressTracker, to: player)
    }

    private func startPictureInPicture() {
        pictureInPicture.start()
        dismiss()
    }

    private var pipImageName: String {
        pictureInPicture.isPictureInPictureActive ? "pip.exit" : "pip.enter"
    }
}

#Preview {
    PipPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
