//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct VanillaPlayerView: View {
    let item: AVPlayerItem

    @StateObject private var player = AVQueuePlayer()

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear(perform: play)
    }

    private func play() {
        player.insert(item, after: nil)
        player.play()
    }
}

#if os(iOS)
extension VanillaPlayerView: SourceCodeViewable {
    static let filePath = #file
}
#endif

// Workaround for FB13126425. Makes it possible to use `AVPlayer` as `@ObservableObject` to avoid memory leaks
// in modal presentations.
extension AVPlayer: @retroactive ObservableObject {}

#Preview {
    VanillaPlayerView(item: URLMedia.appleAdvanced_16_9_TS_HLS.playerItem()!)
}
