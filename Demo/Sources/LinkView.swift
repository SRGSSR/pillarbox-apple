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

struct LinkView: View {
    @StateObject private var player = Player()
    @State private var isDisplayed = true

    var body: some View {
        VStack {
            VideoView(player: isDisplayed ? player : Player())
            Toggle("Content displayed", isOn: $isDisplayed)
                .padding()
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        let item = AVPlayerItem(url: Stream.appleBasic_16_9)
        player.append(item)
        player.play()
    }
}

// MARK: Preview

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView()
    }
}
