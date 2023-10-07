//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, tvOS 17.0, *)
private struct PlaybackSpeedMenuContent: View {
    let speeds: Set<Float>
    @ObservedObject var player: Player

    var body: some View {
        Picker("", selection: player.playbackSpeed) {
            ForEach(playbackSpeeds, id: \.self) { speed in
                Text("\(speed, specifier: "%g×")").tag(speed)
            }
        }
        .pickerStyle(.inline)
    }

    private var playbackSpeeds: [Float] {
        speeds.filter { speed in
            player.playbackSpeedRange.contains(speed)
        }
        .sorted()
    }
}

@available(iOS 16.0, tvOS 17.0, *)
private struct MediaSelectionMenuContent: View {
    let characteristic: AVMediaCharacteristic
    @ObservedObject var player: Player
    @State private var selection: MediaSelectionOption = .automatic

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(mediaOptions, id: \.self) { option in
                Text(option.displayName).tag(option)
            }
        }
        .pickerStyle(.inline)
        .onAppear {
            selection = player.mediaOption(for: characteristic).wrappedValue
        }
        .onChange(of: selection) { value in
            player.mediaOption(for: characteristic).wrappedValue = value
        }
    }

    private var mediaOptions: [MediaSelectionOption] {
        player.mediaSelectionOptions(for: characteristic)
    }
}

@available(iOS 16.0, tvOS 17.0, *)
private struct SettingsMenuContent: View {
    var player: Player

    var body: some View {
        playbackSpeedMenu()
        audibleMediaSelectionMenu()
        legibleMediaSelectionMenu()
    }

    @ViewBuilder
    private func playbackSpeedMenu() -> some View {
        Menu {
            player.playbackSpeedMenu()
        } label: {
            Label {
                Text("Playback Speed", bundle: .module, comment: "Playback setting section")
            } icon: {
                Image(systemName: "speedometer")
            }
        }
    }

    @ViewBuilder
    private func audibleMediaSelectionMenu() -> some View {
        Menu {
            player.mediaSelectionMenu(characteristic: .audible)
        } label: {
            Label {
                Text("Languages", bundle: .module, comment: "Playback setting section")
            } icon: {
                Image(systemName: "waveform.circle")
            }
        }
    }

    @ViewBuilder
    private func legibleMediaSelectionMenu() -> some View {
        Menu {
            player.mediaSelectionMenu(characteristic: .legible)
        } label: {
            Label {
                Text("Subtitles", bundle: .module, comment: "Playback setting section")
            } icon: {
                Image(systemName: "captions.bubble")
            }
        }
    }
}

@available(iOS 16.0, tvOS 17.0, *)
public extension Player {
    /// Returns content for a standard player settings menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func standardSettingMenu() -> some View {
        SettingsMenuContent(player: self)
    }

    /// Returns content for a playback speed menu.
    ///
    /// - Parameter speeds: The offered speeds.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func playbackSpeedMenu(speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2]) -> some View {
        PlaybackSpeedMenuContent(speeds: speeds, player: self)
    }

    /// Returns content for a media selection menu.
    ///
    /// - Parameter characteristic: The characteristic for which selection is made.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func mediaSelectionMenu(characteristic: AVMediaCharacteristic) -> some View {
        MediaSelectionMenuContent(characteristic: characteristic, player: self)
    }
}
