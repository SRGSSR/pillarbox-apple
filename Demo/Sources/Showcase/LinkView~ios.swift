//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LinkView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)
    @State private var isBusy = false
    @State private var isDisplayed = true

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                BasicPlaybackView(player: isDisplayed ? player : Player())
                ProgressView()
                    .opacity(isBusy ? 1 : 0)
                    .accessibilityHidden(true)
            }
            Toggle("Content displayed", isOn: $isDisplayed)
                .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton(topBarStyle: true)
        }
        .onAppear(perform: play)
        .onForeground(perform: resume)
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
        .tracked(name: "link")
    }

    private func play() {
        player.append(media.item())
        player.play()
    }

    private func resume() {
        player.play()
    }
}

extension LinkView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    LinkView(media: URLMedia.onDemandVideoLocalHLS)
}
