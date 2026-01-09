//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct TwinsView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var mode: Mode = .both

    private var topPlayer: Player {
        mode != .bottom ? player : Player(configuration: .externalPlaybackDisabled)
    }

    private var bottomPlayer: Player {
        mode != .top ? player : Player(configuration: .externalPlaybackDisabled)
    }

    var body: some View {
        VStack(spacing: 10) {
            Group {
                BasicPlaybackView(player: topPlayer)
                BasicPlaybackView(player: bottomPlayer)
            }
            .background(.black)

            SwiftUI.Picker(selection: $mode) {
                Text("Both").tag(Mode.both)
                Text("Top").tag(Mode.top)
                Text("Bottom").tag(Mode.bottom)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton(topBarStyle: true)
        }
        .onAppear(perform: play)
        .onForeground(perform: resume)
        .tracked(name: "twins")
    }

    private func play() {
        player.append(media.item())
        player.play()
    }

    private func resume() {
        player.play()
    }
}

private extension TwinsView {
    enum Mode {
        case both
        case top
        case bottom
    }
}

extension TwinsView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TwinsView(media: URLMedia.onDemandVideoLocalHLS)
}
