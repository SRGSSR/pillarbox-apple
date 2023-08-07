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

private struct AudibleMediaOptionsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: selectedMediaOption) {
                ForEach(mediaOptions, id: \.self) { option in
                    Text(option.displayName).tag(option as AVMediaSelectionOption?)
                }
            } label: {
                Text("Languages")
            }
        } label: {
            Label("Languages", systemImage: "waveform.circle")
        }
    }

    private var mediaOptions: [AVMediaSelectionOption] {
        player.mediaSelectionOptions(for: .audible)
    }

    private var selectedMediaOption: Binding<AVMediaSelectionOption?> {
        .init {
            player.selectedMediaOption(for: .audible)
        } set: { newValue in
            player.select(mediaOption: newValue, for: .audible)
        }
    }
}

private struct LegibleMediaOptionsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: selectedMediaOption) {
                Text("None").tag(nil as AVMediaSelectionOption?)
                ForEach(mediaOptions, id: \.self) { option in
                    Text(option.displayName).tag(option as AVMediaSelectionOption?)
                }
            } label: {
                Text("Subtitles")
            }
        } label: {
            Label("Subtitles", systemImage: "captions.bubble")
        }
    }

    private var mediaOptions: [AVMediaSelectionOption] {
        player.mediaSelectionOptions(for: .legible)
    }

    private var selectedMediaOption: Binding<AVMediaSelectionOption?> {
        .init {
            player.selectedMediaOption(for: .legible)
        } set: { newValue in
            player.select(mediaOption: newValue, for: .legible)
        }
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
