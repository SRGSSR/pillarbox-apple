//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private final class MultiAdvancedPiPViewModel: ObservableObject, PictureInPicturePersistable {
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

struct MultiAdvancedPiPView: View {
    let media1: Media
    let media2: Media

    @StateObject private var model = MultiAdvancedPiPViewModel.persisted ?? MultiAdvancedPiPViewModel()

    var body: some View {
        VStack {
            VideoView(player: model.player1)
                .supportsPictureInPicture(model.supportsPictureInPicture1)
                .overlay(alignment: .topTrailing) {
                    PiPButton()
                        .padding()
                }
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $model.supportsPictureInPicture1)
                Button(action: model.player1.togglePlayPause) {
                    Text("Play / pause")
                }
            }
            .padding()

            VideoView(player: model.player2)
                .supportsPictureInPicture(model.supportsPictureInPicture2)
                .overlay(alignment: .topTrailing) {
                    PiPButton()
                        .padding()
                }
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $model.supportsPictureInPicture2)
                Button(action: model.player2.togglePlayPause) {
                    Text("Play / pause")
                }
            }
            .padding()
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
}

extension MultiAdvancedPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    MultiAdvancedPiPView(media1: URLMedia.onDemandVideoLocalHLS, media2: URLMedia.onDemandVideoMP4)
}
