//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS 16.0, tvOS 17.0, *)
struct SettingsMenuContent: View {
    let speeds: Set<Float>
    let action: (SettingsUpdate) -> Void

    @ObservedObject var player: Player

    var body: some View {
        playbackSpeedMenu()
        audibleMediaSelectionMenu()
        legibleMediaSelectionMenu()
    }

    private func playbackSpeedMenu() -> some View {
        SwiftUI.Menu {
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
        SwiftUI.Menu {
            mediaSelectionMenuContent(characteristic: .audible)
        } label: {
            Label {
                Text("Audio", bundle: .module, comment: "Playback setting menu title")
            } icon: {
                Image(systemName: "waveform")
            }
            Text(player.selectedMediaOption(for: .audible).displayName)
        }
    }

    private func legibleMediaSelectionMenu() -> some View {
        SwiftUI.Menu {
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
