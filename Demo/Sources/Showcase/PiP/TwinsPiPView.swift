//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct TwinsPiPView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    @State private var topSupportsPictureInPicture = true
    @State private var bottomSupportsPictureInPicture = true

    var body: some View {
        VStack {
            playbackView(supportsPictureInPicture: $topSupportsPictureInPicture)
            playbackView(supportsPictureInPicture: $bottomSupportsPictureInPicture)
        }
        .onAppear(perform: play)
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "twins-pip")
    }

    private func play() {
        model.media = media
        model.play()
    }

    private func playbackView(supportsPictureInPicture: Binding<Bool>) -> some View {
        VStack {
            PlaybackView(player: model.player)
                .supportsPictureInPicture(supportsPictureInPicture.wrappedValue)

            Toggle("Picture in Picture", isOn: supportsPictureInPicture)
                .padding(.horizontal)
        }
    }
}

extension TwinsPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TwinsPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
