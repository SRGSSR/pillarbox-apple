//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

private struct FullScreenView: View {
    let player: Player

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
            .onTapGesture {
                isPresented.toggle()
            }
            .accessibilityElement()
            .accessibilityLabel("Open full-screen player")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default) {
                isPresented.toggle()
            }
            .onAppear(perform: play)
            .fullScreenCover(isPresented: $isPresented) {
                FullScreenView(player: player)
            }
    }

    private func play() {
        player.enableSilentPlayback(withLanguage: "fr")
        player.append(media.item())
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
        setMediaSelectionPreference(.on(languages: language), for: .legible)
        isMuted = true
    }

    func disableSilentPlayback() {
        textStyleRules = []
        setMediaSelectionPreference(.off, for: .legible)
        isMuted = false
    }
}

extension TransitionView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TransitionView(media: URLMedia.onDemandVideoLocalHLS)
}
