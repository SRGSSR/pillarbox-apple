//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

// Behavior: h-exp, v-exp
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
            CloseButton()
                .padding(.horizontal)
                .frame(minHeight: 35)
        }
        .onAppear(perform: play)
        .onForeground(perform: resume)
        .tracked(name: "wrapped")
    }

    private func play() {
        let player = Player(item: media.playerItem(), configuration: .externalPlaybackDisabled)
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
    WrappedView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
