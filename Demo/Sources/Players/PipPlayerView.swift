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
    @ObservedObject private var pictureInPicture = PictureInPicture.shared

    @State private var isPiPSupportedByFirstView = true

    init(media: Media? = nil) {
        if let media {
            model.replace(with: media)
        }
    }

    var body: some View {
        VStack {
            PlaybackView(player: model.player, supportsPictureInPicture: isPiPSupportedByFirstView)
            PlaybackView(player: model.player, supportsPictureInPicture: !isPiPSupportedByFirstView)
            PipMetadataView()
            Toggle(isOn: $isPiPSupportedByFirstView) {
                Text("PiP in first view")
            }
            .padding()
        }
        .onAppear(perform: model.play)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            pictureInPicture.stop()
        }
        .onDisappear {
            if !pictureInPicture.isActive {
                model.reset()
            }
        }
    }
}

// TODO: 
// - Implement PiP for 2 players and manage router destinations
// - Implement PiP with 2x same content displayed (must be able to pick which view will then provide the layer to the
//   PiP; likely need to have updateUIView update the PiP controller when this changes)

private struct PipMetadataView: View {
    @ObservedObject private var model = PipPlayerViewModel.shared
    @ObservedObject private var pictureInPicture = PictureInPicture.shared
    @Environment(\.dismiss) private var dismiss

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

#Preview {
    PipPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
