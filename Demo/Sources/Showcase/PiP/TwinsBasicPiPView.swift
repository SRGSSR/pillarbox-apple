//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct TwinsBasicPiPView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)

    @State private var topSupportsPictureInPicture = true
    @State private var bottomSupportsPictureInPicture = true

    var body: some View {
        VStack {
            VideoView(player: player)
                .supportsPictureInPicture(topSupportsPictureInPicture)
            Toggle("Supports PiP", isOn: $topSupportsPictureInPicture)

            Button(action: player.togglePlayPause) {
                Text("Play / pause")
            }

            VideoView(player: player)
                .supportsPictureInPicture(bottomSupportsPictureInPicture)
            Toggle("Support PiP", isOn: $bottomSupportsPictureInPicture)
        }
        .onAppear(perform: play)
        .tracked(name: "twins-basic-pip")
    }

    private func play() {
        player.append(media.item())
        player.play()
    }
}

extension TwinsBasicPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TwinsBasicPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
