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
import UserInterface

/*:
    Implementing a basic player is easy, even in a Playground:
        - Instantiate a `Player` as `@StateObject`.
        - Create a view displaying a `VideoView` and add some controls
          to it.
*/

struct PlayerView: View {
    @StateObject private var player = Player(
        item: PlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
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
                Button(action: { player.togglePlayPause() }) {
                    Image(systemName: playbackButtonImage)
                        .resizable()
                        .frame(width: 44, height: 44)
                }
            }
            SliderView(player: player)
        }
        .onAppear {
            player.play()
        }
    }
}

extension PlayerView {
    struct SliderView: View {
        @ObservedObject var player: Player
        @StateObject private var tracker = ProgressTracker(interval: CMTime(value: 1, timescale: 1))

        var body: some View {
            Slider(value: $tracker.progress, in: tracker.range) { isEditing in
                tracker.isInteracting = isEditing
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .bind(tracker, to: player)
        }
    }
}

PlaygroundPage.current.setLiveView(
    PlayerView()
        .frame(width: 500, height: 500)
)
