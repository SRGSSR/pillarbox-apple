//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct MultiPiPView: View {
    let media1: Media
    let media2: Media
    let isSystemPlayer: Bool

    @StateObject private var model = MultiPiPViewModel.persisted ?? MultiPiPViewModel()

    var body: some View {
        VStack {
            playbackView(player: model.player1, supportsPictureInPicture: $model.supportsPictureInPicture1)
            playbackView(player: model.player2, supportsPictureInPicture: $model.supportsPictureInPicture2)
        }
        .onAppear(perform: play)
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "multi-pip")
    }

    private func play() {
        model.media1 = media1
        model.media2 = media2
        model.play()
    }

    private func playbackView(player: Player, supportsPictureInPicture: Binding<Bool>) -> some View {
        VStack {
            playbackView(player: player, supportsPictureInPicture: supportsPictureInPicture.wrappedValue)
            Toggle("Picture in Picture", isOn: supportsPictureInPicture)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func playbackView(player: Player, supportsPictureInPicture: Bool) -> some View {
        if isSystemPlayer {
            SystemVideoView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
        }
        else {
            PlaybackView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
        }
    }
}

extension MultiPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    MultiPiPView(media1: URLMedia.onDemandVideoLocalHLS, media2: URLMedia.onDemandVideoMP4, isSystemPlayer: false)
}
