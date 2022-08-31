//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(tvOS, unavailable)
public extension Slider {
    @MainActor
    init(
        player: Player,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel
    ) {
        self.init(value: Binding(player, at: \.progress.value), label: label, minimumValueLabel: minimumValueLabel, maximumValueLabel: maximumValueLabel)
    }
}

@available(tvOS, unavailable)
public extension Slider where ValueLabel == EmptyView {
    @MainActor
    init(player: Player, @ViewBuilder label: () -> Label) {
        self.init(value: Binding(player, at: \.progress.value), label: label) { isEditing in
            player.progress.isInteracting = isEditing
        }
    }
}

@available(tvOS, unavailable)
public extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    @MainActor
    init(player: Player) {
        self.init(value: Binding(player, at: \.progress.value)) { isEditing in
            player.progress.isInteracting = isEditing
        }
    }
}
