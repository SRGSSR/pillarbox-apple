//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

struct TransitionBasicPiPView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isPresented = false

    var body: some View {
        VideoView(player: player)
            .supportsPictureInPicture()
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                isPresented.toggle()
            }
            .onAppear(perform: play)
            .fullScreenCover(isPresented: $isPresented) {
                VideoView(player: player)
                    .supportsPictureInPicture()
            }
    }

    private func play() {
        player.append(media.item())
        player.play()
    }
}

extension TransitionBasicPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TransitionBasicPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
