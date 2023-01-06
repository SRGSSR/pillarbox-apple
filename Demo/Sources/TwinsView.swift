//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct TwinsView: View {
    let media: Media

    @StateObject var player = Player()
    @State private var mode: Mode = .both

    private var topPlayer: Player {
        mode != .bottom ? player : Player()
    }

    private var bottomPlayer: Player {
        mode != .top ? player : Player()
    }

    var body: some View {
        VStack(spacing: 10) {
            Group {
                PlaybackView(player: topPlayer)
                PlaybackView(player: bottomPlayer)
            }
            .background(.black)

            Picker("Mode", selection: $mode) {
                Text("Both").tag(Mode.both)
                Text("Top").tag(Mode.top)
                Text("Bottom").tag(Mode.bottom)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .onAppear {
            play()
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

// MARK: Types

private extension TwinsView {
    enum Mode {
        case both
        case top
        case bottom
    }
}

// MARK: Preview

struct TwinsView_Previews: PreviewProvider {
    static var previews: some View {
        TwinsView(media: URLTemplate.onDemandVideoLocalHLS.media())
    }
}
