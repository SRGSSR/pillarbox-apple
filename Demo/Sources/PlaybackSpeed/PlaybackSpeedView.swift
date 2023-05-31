//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct SettingsMenu: View {
    @ObservedObject var player: Player
    var body: some View {
        Menu {
            Menu {
                Picker(selection: $player.playbackSpeed) {
                    Text("0.5×").tag(Float(0.5))
                    Text("1×").tag(Float(1))
                    Text("1.25×").tag(Float(1.25))
                    Text("1.5×").tag(Float(1.5))
                    Text("2×").tag(Float(2))
                } label: {
                    Text("Playback Speed")
                }
            } label: {
                Label("Playback Speed", systemImage: "speedometer")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .tint(.white)
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu(player: Player())
            .background(.black)
    }
}
