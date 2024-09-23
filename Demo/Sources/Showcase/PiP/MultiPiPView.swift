//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private final class MultiPiPViewModel: ObservableObject, PictureInPicturePersistable {
    @Published var media1: Media? {
        didSet {
            guard media1 != oldValue else { return }
            Self.update(player: player1, with: media1)
        }
    }

    @Published var media2: Media? {
        didSet {
            guard media2 != oldValue else { return }
            Self.update(player: player2, with: media2)
        }
    }

    @Published var supportsPictureInPicture1 = true
    @Published var supportsPictureInPicture2 = true

    let player1 = Player(configuration: .externalPlaybackDisabled)
    let player2 = Player(configuration: .externalPlaybackDisabled)

    private static func update(player: Player, with media: Media?) {
        if let item = media?.item() {
            player.items = [item]
        }
        else {
            player.removeAllItems()
        }
    }

    func play() {
        player1.play()
        player2.play()
    }
}

struct MultiPiPView: View {
    let media1: Media
    let media2: Media

    @StateObject private var model = MultiPiPViewModel.persisted ?? MultiPiPViewModel()

    var body: some View {
        VStack {
            playbackView(player: model.player1, supportsPictureInPicture: $model.supportsPictureInPicture1)
            playbackView(player: model.player2, supportsPictureInPicture: $model.supportsPictureInPicture2)
        }
        .onAppear(perform: play)
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "multi-advanced-pip")
    }

    private func play() {
        model.media1 = media1
        model.media2 = media2
        model.play()
    }

    private func playbackView(player: Player, supportsPictureInPicture: Binding<Bool>) -> some View {
        VStack {
            PlaybackView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture.wrappedValue)

            Toggle("Supports PiP", isOn: supportsPictureInPicture)
                .padding(.horizontal)
        }
    }
}

extension MultiPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    MultiPiPView(media1: URLMedia.onDemandVideoLocalHLS, media2: URLMedia.onDemandVideoMP4)
}
