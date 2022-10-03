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

struct BasicPlayerView: View {
    @StateObject private var player = Player(item: AVPlayerItem(url: Stream.appleAdvanced_16_9_HEVC_h264))

    var body: some View {
        VideoView(player: player)
            .onAppear {
                player.play()
            }
    }
}

// MARK: Preview

struct BasicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        BasicPlayerView()
    }
}
