//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

struct ContentView: View {
    @StateObject private var player = Player(items: [
        AVPlayerItem(url: URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!),
        AVPlayerItem(url: URL(string: "https://swi-vod.akamaized.net/videoJson/47816310/master.m3u8")!)
    ])

    var body: some View {
        PlayerView(player: player)
            .onAppear {
                player.play()
            }
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
