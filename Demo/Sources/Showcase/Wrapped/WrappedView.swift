//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import AVFoundation
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct WrappedView: View {
    let media: Media

    @StateObject private var model = WrappedViewModel()

    var body: some View {
        VStack(spacing: 10) {
            BasicPlaybackView(player: model.player)
            HStack {
                Button(action: play) {
                    Text("Play")
                }
                Button(action: stop) {
                    Text("Stop")
                }
            }
            .padding()
        }
        .onAppear(perform: play)
        .tracked(title: "Wrapped")
    }

    private func play() {
        let player = Player(item: media.playerItem(), configuration: .externalPlaybackDisabled)
        model.player = player
        player.play()
    }

    private func stop() {
        model.player = Player(configuration: .externalPlaybackDisabled)
    }
}

struct WrappedView_Previews: PreviewProvider {
    static var previews: some View {
        WrappedView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
