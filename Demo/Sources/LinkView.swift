//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct LinkView: View {
    let media: Media

    @StateObject private var player = Player()
    @State private var isDisplayed = true

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                BasicPlaybackView(player: isDisplayed ? player : Player())
                if player.isBuffering {
                    ProgressView()
                }
            }
            Toggle("Content displayed", isOn: $isDisplayed)
                .padding()
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

// MARK: Preview

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(media: URLTemplate.onDemandVideoLocalHLS.media())
    }
}
