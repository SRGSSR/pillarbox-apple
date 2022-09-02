//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

@available(tvOS, unavailable)
public extension Slider {
    /// Create a slider bound to a player.
    /// - Parameters:
    ///   - player: The player.
    ///   - label: A view describing the slider purpose.
    ///   - minimumValueLabel: A view describing the lower bound.
    ///   - maximumValueLabel: A view describing the upper bound.
    @MainActor
    init(
        player: Player,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel
    ) {
        self.init(
            value: sliderValue(for: player),
            in: sliderBounds(for: player),
            label: label,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        )
    }
}

@available(tvOS, unavailable)
public extension Slider where ValueLabel == EmptyView {
    /// Create a slider bound to a player.
    /// - Parameters:
    ///   - player: The player.
    ///   - label: A view describing the slider purpose.
    @MainActor
    init(player: Player, @ViewBuilder label: () -> Label) {
        self.init(
            value: sliderValue(for: player),
            in: sliderBounds(for: player),
            label: label
        ) { isEditing in
            player.isUpdatingProgressInteractively = isEditing
        }
    }
}

@available(tvOS, unavailable)
public extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    /// Create a slider bound to a player.
    /// - Parameters:
    ///   - player: The player.
    @MainActor
    init(player: Player) {
        self.init(value: sliderValue(for: player), in: sliderBounds(for: player)) { isEditing in
            player.isUpdatingProgressInteractively = isEditing
        }
    }
}

@MainActor
private func sliderValue(for player: Player) -> Binding<Float> {
    Binding(player, at: \.progress)
}

@MainActor
private func sliderBounds(for player: Player) -> ClosedRange<Float> {
    0...1
}
