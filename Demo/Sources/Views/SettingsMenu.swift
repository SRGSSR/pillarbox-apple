//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

private struct PlaybackSpeedMenu: View {
    static let speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2]
    private var speeds: [Float] {
        Self.speeds.filter { speed in
            player.playbackSpeedRange.contains(speed)
        }
        .sorted()
    }
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: $player.playbackSpeed) {
                ForEach(speeds, id: \.self) { speed in
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
                .frame(width: 45)
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu(player: Player())
            .background(.black)
    }
}
