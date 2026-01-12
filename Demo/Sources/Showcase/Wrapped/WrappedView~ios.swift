//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct WrappedView: View {
    let media: Media

    @StateObject private var model = WrappedViewModel()

    var body: some View {
        VStack(spacing: 10) {
            BasicPlaybackView(player: model.player)
            HStack {
                Button(action: play) {
                    Text("Play")
                }
                Button(action: stop) {
                    Text("Stop")
                }
            }
            .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton(topBarStyle: true)
        }
        .onAppear(perform: play)
        .onForeground(perform: resume)
        .tracked(name: "wrapped")
    }

    private func play() {
        let player = Player(item: media.item(), configuration: .externalPlaybackDisabled)
        model.player = player
        player.play()
    }

    private func resume() {
        model.player.play()
    }

    private func stop() {
        model.player = Player(configuration: .externalPlaybackDisabled)
    }
}

extension WrappedView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    WrappedView(media: URLMedia.onDemandVideoHLS)
}
