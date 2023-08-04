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
    private static let speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2]

    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: playbackSpeed) {
                ForEach(speeds.reversed(), id: \.self) { speed in
                    Text("\(speed, specifier: "%g×")").tag(speed)
                }
            } label: {
                Text("Playback Speed")
            }
        } label: {
            Label("Playback Speed", systemImage: "speedometer")
        }
    }

    private var speeds: [Float] {
        Self.speeds.filter { speed in
            player.playbackSpeedRange.contains(speed)
        }
        .sorted()
    }

    private var playbackSpeed: Binding<Float> {
        .init {
            player.effectivePlaybackSpeed
        } set: { newValue in
            player.setDesiredPlaybackSpeed(newValue)
        }
    }
}

private struct AudibleMediaOptionsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        if mediaOptions.count > 1 {
            Menu {
                ForEach(mediaOptions, id: \.self) { option in
                    Text(option.displayName)
                }
            } label: {
                Label("Languages", systemImage: "waveform.circle")
            }
        }
    }

    private var mediaOptions: [AVMediaSelectionOption] {
        player.mediaSelectionOptions(for: .audible)
    }
}

private struct LegibleMediaOptionsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        if mediaOptions.count > 1 {
            Menu {
                ForEach(mediaOptions, id: \.self) { option in
                    Text(option.displayName)
                }
            } label: {
                Label("Subtitles", systemImage: "captions.bubble")
            }
        }
    }

    private var mediaOptions: [AVMediaSelectionOption] {
        player.mediaSelectionOptions(for: .legible)
    }
}

struct SettingsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            PlaybackSpeedMenu(player: player)
            AudibleMediaOptionsMenu(player: player)
            LegibleMediaOptionsMenu(player: player)
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

#endif
