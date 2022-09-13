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

    private var topPlayer: Player? {
        mode != .bottom ? player : nil
    }

    private var bottomPlayer: Player? {
        mode != .top ? player : nil
    }

    var body: some View {
        VStack {
            Group {
                VideoView(player: topPlayer)
                VideoView(player: bottomPlayer)
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
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
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
