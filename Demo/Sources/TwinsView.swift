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

struct TwinsView: View {
    @StateObject var player = Player()
    @State private var mode: Mode = .both

    private var topPlayer: Player {
        mode != .bottom ? player : Player()
    }

    private var bottomPlayer: Player {
        mode != .top ? player : Player()
    }

    var body: some View {
        VStack {
            Group {
                BasicPlayerView(player: topPlayer)
                BasicPlayerView(player: bottomPlayer)
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
        let item = AVPlayerItem(url: Stream.appleAdvanced)
        player.append(item)
        player.play()
    }
}

// MARK: Types

extension TwinsView {
    enum Mode {
        case both
        case top
        case bottom
    }
}

// MARK: Preview

struct TwinsView_Previews: PreviewProvider {
    static var previews: some View {
        TwinsView()
    }
}
