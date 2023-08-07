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

private struct MediaOptionsMenu: View {
    let characteristic: AVMediaCharacteristic
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            Picker(selection: selectedMediaOption) {
                ForEach(mediaOptions.reversed(), id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            } label: {
                Text(title)
            }
        } label: {
            Label(title, systemImage: icon)
        }
    }

    private var title: String {
        switch characteristic {
        case .legible:
            return "Subtitles"
        default:
            return "Languages"
        }
    }

    private var icon: String {
        switch characteristic {
        case .legible:
            return "captions.bubble"
        default:
            return "waveform.circle"
        }
    }

    private var mediaOptions: [MediaSelectionOption] {
        player.mediaSelectionOptions(for: characteristic)
    }

    private var selectedMediaOption: Binding<MediaSelectionOption> {
        .init {
            player.selectedMediaOption(for: characteristic)
        } set: { newValue in
            player.select(mediaOption: newValue, for: characteristic)
        }
    }
}

struct SettingsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
        Menu {
            MediaOptionsMenu(characteristic: .legible, player: player)
            MediaOptionsMenu(characteristic: .audible, player: player)
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

#endif
