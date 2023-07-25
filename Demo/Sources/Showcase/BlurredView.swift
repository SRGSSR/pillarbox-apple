//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Combine
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct BlurredView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)

    var body: some View {
        ZStack {
            VideoView(player: player, gravity: .resizeAspectFill)
                .blur(radius: 20)
            VideoView(player: player)
                .ignoresSafeArea()
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
        }
        .background(.black)
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onAppear(perform: play)
        .onForeground(perform: player.play)
        .tracked(name: "blurred")
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

struct BlurredView_Previews: PreviewProvider {
    static var previews: some View {
        BlurredView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
