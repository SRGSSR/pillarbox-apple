//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS 16.0, tvOS 17.0, *)
struct PlaybackSpeedMenuContent: View {
    let speeds: Set<Float>
    let action: (Float) -> Void

    @ObservedObject var player: Player

    var body: some View {
        SwiftUI.Picker(selection: selection) {
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
