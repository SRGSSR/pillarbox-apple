//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

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
        .onAppear(perform: play)
        .tracked(name: "tracking")
    }

    private func play() {
        player.append(media.playerItem())
        player.becomeActive()
        player.play()
    }
}

#Preview {
    OptInView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
