//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A standard menu to display playback speeds.
@available(iOS 16.0, tvOS 17.0, *)
public struct PlaybackSpeedMenu: View {
    private let speeds: Set<Float>
    @ObservedObject private var player: Player

    public var body: some View {
        // TODO: Remove when Xcode 15 has been released
#if os(iOS) || compiler(>=5.9)
        Menu {
            Picker(selection: player.playbackSpeed) {
                ForEach(playbackSpeeds, id: \.self) { speed in
                    Text("\(speed, specifier: "%g×")").tag(speed)
                }
            } label: {
                Text("Playback Speed")
            }
        } label: {
            Label("Playback Speed", systemImage: "speedometer")
        }
#endif
    }

    private var playbackSpeeds: [Float] {
        speeds.filter { speed in
            player.playbackSpeedRange.contains(speed)
        }
        .sorted()
        .reversed()
    }

    /// Creates a menu display playback speeds available for playback.
    ///
    /// The speed 1× is always added to the provided list. Speeds made available will be restricted to values
    /// compatible with `Player.playbackSpeedRange`.
    ///
    /// - Parameters:
    ///   - speeds: The speeds to display.
    ///   - player: The player to display speeds for.
    public init(speeds: Set<Float>, player: Player) {
        self.speeds = speeds.union([1])
        self.player = player
    }
}
