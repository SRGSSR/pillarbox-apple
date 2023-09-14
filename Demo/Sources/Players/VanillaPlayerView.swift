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

    @StateObject private var player = AVQueuePlayer()

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                CloseButton()
            }
            .onAppear(perform: play)
    }

    private func play() {
        player.insert(item, after: nil)
        player.play()
    }
}

// Workaround for FB13126425. Makes it possible to use `AVPlayer` as `@ObservableObject` to avoid memory leaks
// in modal presentations.
extension AVPlayer: ObservableObject {}

#Preview {
    VanillaPlayerView(item: Template.playerItem(from: URLTemplate.appleAdvanced_16_9_TS_HLS)!)
}
