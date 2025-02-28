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
    let action: (Float) -> Void

    @ObservedObject var player: Player

    var body: some View {
        Picker("Playback Speed", selection: selection) {
            ForEach(playbackSpeeds, id: \.self) { speed in
                Text("\(speed, specifier: "%g×")", comment: "Speed multiplier").tag(speed)
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

    private var selection: Binding<Float> {
        .init {
            player.playbackSpeed.wrappedValue
        } set: { newValue in
            player.playbackSpeed.wrappedValue = newValue
            action(newValue)
        }
    }
}

@available(iOS 16.0, tvOS 17.0, *)
private struct MediaSelectionMenuContent: View {
    let characteristic: AVMediaCharacteristic
    let action: (MediaSelectionOption) -> Void

    @ObservedObject var player: Player

    private var title: String {
        switch characteristic {
        case .audible:
            "Languages"
        case .legible:
            "Subtitles"
        default:
            ""
        }
    }

    var body: some View {
        Picker(title, selection: selection(for: characteristic)) {
            ForEach(mediaOptions, id: \.self) { option in
                Text(option.displayName).tag(option)
            }
        }
        .pickerStyle(.inline)
    }

    private var mediaOptions: [MediaSelectionOption] {
        player.mediaSelectionOptions(for: characteristic)
    }

    private func selection(for characteristic: AVMediaCharacteristic) -> Binding<MediaSelectionOption> {
        .init {
            player.mediaOption(for: characteristic).wrappedValue
        } set: { newValue in
            player.mediaOption(for: characteristic).wrappedValue = newValue
            action(newValue)
        }
    }
}

@available(iOS 16.0, tvOS 17.0, *)
private struct SettingsMenuContent: View {
    let player: Player

    var body: some View {
        playbackSpeedMenu()
        audibleMediaSelectionMenu()
        legibleMediaSelectionMenu()
    }

    private func playbackSpeedMenu() -> some View {
        Menu {
            player.playbackSpeedMenu()
        } label: {
            Label {
                Text("Playback Speed", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "speedometer")
            }
        }
    }

    private func audibleMediaSelectionMenu() -> some View {
        Menu {
            player.mediaSelectionMenu(characteristic: .audible)
        } label: {
            Label {
                Text("Languages", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "waveform.circle")
            }
        }
    }

    private func legibleMediaSelectionMenu() -> some View {
        Menu {
            player.mediaSelectionMenu(characteristic: .legible)
        } label: {
            Label {
                Text("Subtitles", bundle: .module, comment: "Playback setting menu title")
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
    ///
    func standardSettingsMenu() -> some View {
        SettingsMenuContent(player: self)
    }

    /// Returns content for a playback speed menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered speeds.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func playbackSpeedMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ speed: Float) -> Void = { _ in }
    ) -> some View {
        PlaybackSpeedMenuContent(speeds: speeds, action: action, player: self)
    }

    /// Returns content for a media selection menu.
    ///
    /// - Parameters:
    ///    - characteristic: The characteristic for which selection is made.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func mediaSelectionMenu(
        characteristic: AVMediaCharacteristic,
        action: @escaping (_ option: MediaSelectionOption) -> Void = { _ in }
    ) -> some View {
        MediaSelectionMenuContent(characteristic: characteristic, action: action, player: self)
    }
}
