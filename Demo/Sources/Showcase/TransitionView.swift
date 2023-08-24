//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

private struct FullScreenView: View {
    @ObservedObject var player: Player

    var body: some View {
        PlaybackView(player: player)
            .onAppear {
                player.setMediaSelectionCriteria(preferredLanguages: [], for: .legible)
                player.isMuted = false
            }
            .onDisappear {
                player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .legible)
                player.isMuted = true
            }
    }
}

struct TransitionView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isPresented = false

    var body: some View {
        VideoView(player: player)
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                isPresented.toggle()
            }
            .onAppear(perform: play)
            .sheet(isPresented: $isPresented) {
                FullScreenView(player: player)
            }
    }

    private func play() {
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .legible)
        player.isMuted = true
        player.append(media.playerItem())
        player.play()
    }
}

struct TransitionView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
