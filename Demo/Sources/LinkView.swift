//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

// Behavior: h-exp, v-exp
struct LinkView: View {
    let media: Media

    @StateObject private var player = Player()
    @State private var isDisplayed = true

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                PlaybackView(player: isDisplayed ? player : Player())
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
        guard let item = media.playerItem else { return }
        player.append(item)
        player.play()
    }
}

// MARK: Preview

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(media: MediaURL.onDemandVideoLocalHLS)
    }
}
