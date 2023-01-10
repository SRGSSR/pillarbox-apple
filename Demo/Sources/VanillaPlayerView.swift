//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

// Behavior: h-exp, v-exp
struct VanillaPlayerView: View {
    let item: AVPlayerItem

    @State private var player = AVQueuePlayer()

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
                play()
            }
    }

    private func play() {
        player.insert(item, after: nil)
        player.play()
    }
}

struct VanillaPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VanillaPlayerView(item: Template.playerItem(from: URLTemplate.appleAdvanced_16_9_TS_HLS)!)
    }
}
