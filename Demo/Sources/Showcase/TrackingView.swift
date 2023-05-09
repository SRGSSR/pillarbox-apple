//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Player
import SwiftUI

struct TrackingView: View {
    let media: Media
    @StateObject var player = Player(configuration: .standard)

    var body: some View {
        VStack {
            PlaybackView(player: player)
            VStack(alignment: .leading) {
                Toggle(isOn: $player.isTrackingEnabled) {
                    Text("Tracking")
                }
                Label("Use a proxy tool to observe events.", systemImage: "eyes")
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(.black)
        .onAppear(perform: load)
        .tracked(title: "Tracking")
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
