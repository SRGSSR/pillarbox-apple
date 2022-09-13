//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI
import UserInterface

// MARK: View

struct BasicPlayerView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            VideoView(player: player)
            if player.isBuffering {
                ProgressView()
            }
        }
    }
}

// MARK: Preview

struct BasicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        BasicPlayerView(player: Player())
            .background(.black)
            .previewLayout(.fixed(width: 320, height: 180))
    }
}
