//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

/// A standard menu to display media selection options.
@available(iOS 16.0, tvOS 17.0, *)
public struct MediaSelectionMenu: View {
    private let characteristic: AVMediaCharacteristic
    @ObservedObject private var player: Player

    public var body: some View {
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
    
    /// Creates a menu display options associated with a specific characteristic.
    ///
    /// - Parameters:
    ///   - characteristic: The characteristic.
    ///   - player: The player to display options for.
    public init(characteristic: AVMediaCharacteristic, player: Player) {
        self.characteristic = characteristic
        self.player = player
    }
}
