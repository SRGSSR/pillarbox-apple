//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

struct VideoLinkView: View {
    @StateObject private var player = Player()
    @State private var isDisplayed = true

    var body: some View {
        VStack {
            VideoView(player: isDisplayed ? player : nil)
            Toggle("Player content displayed", isOn: $isDisplayed)
                .padding()
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        player.append(item)
        player.play()
    }
}

// MARK: Preview

struct VideoLinkView_Previews: PreviewProvider {
    static var previews: some View {
        VideoLinkView()
    }
}
