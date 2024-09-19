//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct MultiBasicPiPView: View {
    let media1: Media
    let media2: Media

    @StateObject private var player1 = Player(configuration: .externalPlaybackDisabled)
    @StateObject private var player2 = Player(configuration: .externalPlaybackDisabled)

    @State private var topSupportsPictureInPicture = true
    @State private var bottomSupportsPictureInPicture = true

    var body: some View {
        VStack {
            VideoView(player: player1)
                .supportsPictureInPicture(topSupportsPictureInPicture)
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $topSupportsPictureInPicture)
                Button(action: player1.togglePlayPause) {
                    Text("Play / pause")
                }
            }
            .padding(.horizontal)

            VideoView(player: player2)
                .supportsPictureInPicture(bottomSupportsPictureInPicture)
            VStack(spacing: 20) {
                Toggle("Supports PiP", isOn: $bottomSupportsPictureInPicture)
                Button(action: player2.togglePlayPause) {
                    Text("Play / pause")
                }
            }
            .padding(.horizontal)
        }
        .onAppear(perform: play)
        .tracked(name: "multi-basic-pip")
    }

    private func play() {
        player1.append(media1.item())
        player1.play()

        player2.append(media2.item())
        player2.play()
    }
}

extension MultiBasicPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    MultiBasicPiPView(media1: URLMedia.onDemandVideoLocalHLS, media2: URLMedia.onDemandVideoMP4)
}
