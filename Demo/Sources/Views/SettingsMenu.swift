//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Core
import Player
import SwiftUI

#if os(iOS)

private struct PlaybackSpeedMenu: View {
    private static let playbackSpeeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2]

    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: selectedPlaybackSpeed) {
                ForEach(playbackSpeeds.reversed(), id: \.self) { speed in
                    Text("\(speed, specifier: "%g×")").tag(speed)
                }
            } label: {
                Text("Playback Speed")
            }
        } label: {
            Label("Playback Speed", systemImage: "speedometer")
        }
    }

    private var playbackSpeeds: [Float] {
        Self.playbackSpeeds.filter { speed in
            player.playbackSpeedRange.contains(speed)
        }
        .sorted()
    }

    private var selectedPlaybackSpeed: Binding<Float> {
        .init {
            player.effectivePlaybackSpeed
        } set: { newValue in
            player.setDesiredPlaybackSpeed(newValue)
        }
    }
}

struct SettingsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            MediaSelectionMenu(characteristic: .legible, player: player)
            MediaSelectionMenu(characteristic: .audible, player: player)
            PlaybackSpeedMenu(player: player)
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .tint(.white)
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu(player: Player())
            .background(.black)
    }
}

#endif
