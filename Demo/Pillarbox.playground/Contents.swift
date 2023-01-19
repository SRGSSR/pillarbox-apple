//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// ⚠️ This Playground does not compile with the Pillarbox-demo scheme selected.

import AVFoundation
import Player
import PlaygroundSupport
import SwiftUI

/*:
    Implementing a basic player is easy, even in a Playground:
        - Instantiate a `Player` as `@StateObject`.
        - Create a view displaying a `VideoView` and add some controls
          to it.
*/

// Behavior: h-exp, v-exp
private struct TimeSlider: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 10))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .bind(progressTracker, to: player)
    }
}

// Behavior: h-exp, v-exp
struct PlayerView: View {
    @StateObject private var player = Player(
        item: PlayerItem.simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    private var playbackButtonImage: String? {
        switch player.playbackState {
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        default:
            return nil
        }
    }

    var body: some View {
        ZStack {
            VideoView(player: player)
            if let playbackButtonImage {
                Button(action: player.togglePlayPause) {
                    Image(systemName: playbackButtonImage)
                        .resizable()
                        .frame(width: 44, height: 44)
                }
            }
            TimeSlider(player: player)
        }
        .onAppear {
            player.play()
        }
    }
}

PlaygroundPage.current.setLiveView(
    PlayerView()
        .frame(width: 500, height: 500)
)
