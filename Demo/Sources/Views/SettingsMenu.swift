//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

private struct PlaybackSpeedMenu: View {
    var speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2]
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: $player.playbackSpeed) {
                ForEach(Array(speeds), id: \.self) { speed in
                    Text("\(speed, specifier: "%g×")").tag(speed)
                }
            } label: {
                Text("Playback Speed")
            }
        } label: {
            Label("Playback Speed", systemImage: "speedometer")
        }
    }
}

struct SettingsMenu: View {
    @ObservedObject var player: Player
    var body: some View {
        Menu {
            PlaybackSpeedMenu(player: player)
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
