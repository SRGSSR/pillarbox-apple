//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct MonoscopicPlayerView: View {
    let media: Media

    @StateObject private var player = Player()

    var body: some View {
        MonoscopicVideoView(player: player)
            .onAppear(perform: play)
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

extension MonoscopicPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    MonoscopicPlayerView(media: Media(from: URLTemplate.gothard_360))
}
