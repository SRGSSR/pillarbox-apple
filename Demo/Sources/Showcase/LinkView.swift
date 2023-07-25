//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct LinkView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isDisplayed = true

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                BasicPlaybackView(player: isDisplayed ? player : Player())
                ProgressView()
                    .opacity(player.isBusy ? 1 : 0)
            }
            Toggle("Content displayed", isOn: $isDisplayed)
                .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onAppear(perform: play)
        .onForeground(perform: resume)
        .tracked(name: "link")
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }

    private func resume() {
        player.play()
    }
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
