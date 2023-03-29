//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct TrackingView: View {
    let media: Media
    @StateObject var player = Player(configuration: .standard)

    var body: some View {
        VStack {
            PlaybackView(player: player)
            Toggle(isOn: $player.isTrackingEnabled) {
                Label("Tracking", systemImage: "eyes")
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(.black)
        .onAppear(perform: load)
    }

    private func load() {
        player.append(media.playerItem())
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
