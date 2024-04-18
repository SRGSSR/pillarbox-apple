//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct ChaptersView: View {
    private let player = Player()
    let media: Media

    var body: some View {
        PlaybackView(player: player)
            .onAppear(perform: play)
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

extension ChaptersView: SourceCodeViewable {
    static let filePath = #file
}
