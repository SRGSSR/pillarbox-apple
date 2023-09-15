//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

private struct FullScreenView: View {
    @ObservedObject var player: Player

    var body: some View {
        PlaybackView(player: player)
            .onAppear {
                player.disableSilentPlayback()
            }
            .onDisappear {
                player.enableSilentPlayback(withLanguage: "fr")
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
        player.enableSilentPlayback(withLanguage: "fr")
        player.append(media.playerItem())
        player.play()
    }
}

private extension Player {
    func enableSilentPlayback(withLanguage language: String) {
        let textStyleRule = AVTextStyleRule(textMarkupAttributes: [
            kCMTextMarkupAttribute_BackgroundColorARGB: [1, 1, 0, 0],
            kCMTextMarkupAttribute_ItalicStyle: true
        ])
        textStyleRules = [textStyleRule]
        setMediaSelection(preferredLanguages: [language], for: .legible)
        isMuted = true
    }

    func disableSilentPlayback() {
        textStyleRules = []
        setMediaSelection(preferredLanguages: [], for: .legible)
        isMuted = false
    }
}

#Preview {
    TransitionView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
