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
        Picker(selection: selection) {
            ForEach(playbackSpeeds, id: \.self) { speed in
                Text("\(speed, specifier: "%g×")", bundle: .module, comment: "Speed multiplier").tag(speed)
            }
        } label: {
            EmptyView()
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
            player.playbackSpeed
        } set: { newValue in
            player.playbackSpeed = newValue
            action(newValue)
        }
    }
}

@available(iOS 16.0, tvOS 17.0, *)
private struct MediaSelectionMenuContent: View {
    let characteristic: AVMediaCharacteristic
    let action: (MediaSelectionOption) -> Void

    @ObservedObject var player: Player

    var body: some View {
        Picker(selection: selection(for: characteristic)) {
            ForEach(mediaOptions, id: \.self) { option in
                Text(option.displayName).tag(option)
            }
        } label: {
            EmptyView()
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
private struct GravityMenuContent: View {
    private static let gravities: [AVLayerVideoGravity] = [.resizeAspect, .resizeAspectFill]

    @Binding var gravity: AVLayerVideoGravity
    let action: (AVLayerVideoGravity) -> Void

    @ObservedObject var player: Player

    var body: some View {
        if player.mediaType == .video {
            Menu {
                Picker(selection: selection) {
                    ForEach(Self.gravities, id: \.self) { gravity in
                        Self.description(for: gravity).tag(gravity)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            } label: {
                Label {
                    Text("Display", bundle: .module, comment: "Playback setting menu title")
                } icon: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
                Self.description(for: gravity)
            }
        }
    }

    private var selection: Binding<AVLayerVideoGravity> {
        .init {
            gravity
        } set: { newValue in
            gravity = newValue
            action(newValue)
        }
    }

    private static func description(for gravity: AVLayerVideoGravity) -> Text {
        switch gravity {
        case .resizeAspectFill:
            return Text("Full-screen", bundle: .module, comment: "Display option")
        default:
            return Text("Fit-to-screen", bundle: .module, comment: "Display option")
        }
    }
}

@available(iOS 16.0, tvOS 17.0, *)
private struct SettingsMenuContent: View {
    let speeds: Set<Float>
    let action: (SettingsUpdate) -> Void

    @ObservedObject var player: Player

    var body: some View {
        playbackSpeedMenu()
        audibleMediaSelectionMenu()
        legibleMediaSelectionMenu()
    }

    private func playbackSpeedMenu() -> some View {
        Menu {
            player.playbackSpeedMenu(speeds: speeds) { speed in
                action(.playbackSpeed(speed))
            }
        } label: {
            Label {
                Text("Playback Speed", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "speedometer")
            }
            Text("\(player.playbackSpeed, specifier: "%g×")", bundle: .module, comment: "Speed multiplier")
        }
    }

    private func audibleMediaSelectionMenu() -> some View {
        Menu {
            mediaSelectionMenuContent(characteristic: .audible)
        } label: {
            Label {
                Text("Audio", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "waveform.circle")
            }
            Text(player.selectedMediaOption(for: .audible).displayName)
        }
    }

    private func legibleMediaSelectionMenu() -> some View {
        Menu {
            mediaSelectionMenuContent(characteristic: .legible)
        } label: {
            Label {
                Text("Subtitles", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "captions.bubble")
            }
            Text(player.selectedMediaOption(for: .legible).displayName)
        }
    }

    private func mediaSelectionMenuContent(characteristic: AVMediaCharacteristic) -> some View {
        player.mediaSelectionMenu(characteristic: characteristic) { option in
            action(.mediaSelection(characteristic: characteristic, option: option))
        }
    }
}

@available(iOS 16.0, tvOS 17.0, *)
public extension Player {
    /// Returns content for a standard player settings menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func standardSettingsMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ update: SettingsUpdate) -> Void = { _ in }
    ) -> some View {
        SettingsMenuContent(speeds: speeds, action: action, player: self)
    }

    /// Returns content for a playback speed settings menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user selects an item from the menu.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    func playbackSpeedMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ speed: Float) -> Void = { _ in }
    ) -> some View {
        PlaybackSpeedMenuContent(speeds: speeds, action: action, player: self)
    }

    /// Returns content for a media selection settings menu.
    ///
    /// - Parameters:
    ///    - characteristic: The characteristic for which selection is made.
    ///    - action: The action to perform when the user selects an item from the menu.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    func mediaSelectionMenu(
        characteristic: AVMediaCharacteristic,
        action: @escaping (_ option: MediaSelectionOption) -> Void = { _ in }
    ) -> some View {
        MediaSelectionMenuContent(characteristic: characteristic, action: action, player: self)
    }

    /// Returns the content for a gravity settings menu.
    ///
    /// - Parameters:
    ///   - gravity: A binding to the gravity value to control.
    ///   - action: The action to perform when the user selects an item from the menu.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    func gravityMenu(
        updating gravity: Binding<AVLayerVideoGravity>,
        action: @escaping (_ gravity: AVLayerVideoGravity) -> Void = { _ in }
    ) -> some View {
        GravityMenuContent(gravity: gravity, action: action, player: self)
    }
}
