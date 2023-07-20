//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Player
import SwiftUI

struct OptInView: View {
    let media: Media
    @StateObject private var player = Player(configuration: .standard)

    @State private var isActive = true

    var body: some View {
        VStack {
            PlaybackView(player: player)
            VStack(alignment: .leading) {
                Toggle(isOn: $isActive) {
                    Text("Active")
                }
                Toggle(isOn: $player.isTrackingEnabled) {
                    Text("Tracking")
                }
                Label("Use a proxy tool to observe events.", systemImage: "eyes")
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(.black)
        .onChange(of: isActive) { newValue in
            if newValue {
                player.becomeActive()
            }
            else {
                player.resignActive()
            }
        }
        .onAppear(perform: load)
        .tracked(name: "tracking")
    }

    private func load() {
        player.append(media.playerItem())
    }
}

struct OptInView_Previews: PreviewProvider {
    static var previews: some View {
        OptInView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
