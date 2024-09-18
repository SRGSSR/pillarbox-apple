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

    var body: some View {
        VStack {
            VideoView(player: player)
                .supportsPictureInPicture()

            Button(action: player.togglePlayPause) {
                Text("Play / pause")
            }

            VideoView(player: player)
                .supportsPictureInPicture()
        }
        .onAppear(perform: play)
        .tracked(name: "simple-twins")
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
