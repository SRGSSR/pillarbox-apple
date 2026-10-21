//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct ArtworkView: View {
    @ObservedObject var player: Player

    var body: some View {
        if player.mediaType == .audio {
            LazyImage(source: player.metadata.imageSource) { image in
                image
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
        }
    }
}
