//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct TrackingVisibilityTutorial: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    @StateObject private var visibilityTracker = VisibilityTracker()

    var body: some View {
        // swiftlint:disable:next accessibility_trait_for_button
        ZStack {
            VideoView(player: player)
            controls()
        }
        .onAppear(perform: player.play)
        .onTapGesture(perform: visibilityTracker.toggle)
        .bind(visibilityTracker, to: player)
    }

    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.6)
                .ignoresSafeArea()
            playbackButton()
        }
        .opacity(visibilityTracker.isUserInterfaceHidden ? 0 : 1)
        .animation(.linear, value: visibilityTracker.isUserInterfaceHidden)
    }

    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.shouldPlay ? "pause.circle" : "play.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .tint(.white)
        }
    }
}

#Preview {
    TrackingVisibilityTutorial()
}
