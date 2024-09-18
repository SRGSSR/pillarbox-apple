//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct TwinsAdvancedPiPView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    @State private var topSupportsPictureInPicture = true
    @State private var bottomSupportsPictureInPicture = true

    var body: some View {
        VStack(spacing: 20) {
            VideoView(player: model.player)
                .supportsPictureInPicture(topSupportsPictureInPicture)
                .overlay(alignment: .topTrailing) {
                    PiPButton()
                        .padding()
                }
            Toggle("Supports PiP", isOn: $topSupportsPictureInPicture)

            Button(action: model.player.togglePlayPause) {
                Text("Play / pause")
            }

            VideoView(player: model.player)
                .supportsPictureInPicture(bottomSupportsPictureInPicture)
                .overlay(alignment: .topTrailing) {
                    PiPButton()
                        .padding()
                }
            Toggle("Support PiP", isOn: $bottomSupportsPictureInPicture)
        }
        .onAppear(perform: play)
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "twins-basic-pip")
    }

    private func play() {
        model.media = media
        model.play()
    }
}

extension TwinsAdvancedPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TwinsAdvancedPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
