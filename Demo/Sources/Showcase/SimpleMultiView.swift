//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SimpleMultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var player1 = Player(configuration: .externalPlaybackDisabled)
    @StateObject private var player2 = Player(configuration: .externalPlaybackDisabled)

    var body: some View {
        VStack {
            VideoView(player: player1)
                .supportsPictureInPicture()
            Button(action: player1.togglePlayPause) {
                Text("Play / pause")
            }

            VideoView(player: player2)
                .supportsPictureInPicture()
            Button(action: player2.togglePlayPause) {
                Text("Play / pause")
            }
        }
        .onAppear(perform: play)
        .tracked(name: "simple-multi")
    }

    private func play() {
        player1.append(media1.item())
        player1.play()

        player2.append(media2.item())
        player2.play()
    }
}

extension SimpleMultiView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    SimpleMultiView(media1: URLMedia.onDemandVideoLocalHLS, media2: URLMedia.onDemandVideoMP4)
}
