//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct BlurredView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isBusy = false

    var body: some View {
        ZStack {
            VideoView(player: player)
                .gravity(.resizeAspectFill)
                .blur(radius: 20)
            VideoView(player: player)
                .ignoresSafeArea()
            ProgressView()
                .opacity(isBusy ? 1 : 0)
        }
        .background(.black)
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onAppear(perform: play)
        .onForeground(perform: player.play)
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
        .tracked(name: "blurred")
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

extension BlurredView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    BlurredView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
