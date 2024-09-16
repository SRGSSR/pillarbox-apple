//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

struct SimpleTransitionView: View {
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
                PlaybackView(player: player)
                    .supportsPictureInPicture()
            }
    }

    private func play() {
        player.append(media.item())
        player.play()
    }
}

extension SimpleTransitionView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    SimpleTransitionView(media: URLMedia.onDemandVideoLocalHLS)
}
