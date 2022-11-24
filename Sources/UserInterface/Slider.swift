//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(tvOS, unavailable)
public extension Slider {
    /// Create a slider bound to a progress tracker.
    /// - Parameters:
    ///   - progressTracker: The progress tracker.
    ///   - label: A view describing the slider purpose.
    ///   - minimumValueLabel: A view describing the lower bound.
    ///   - maximumValueLabel: A view describing the upper bound.
    @MainActor
    init(
        progressTracker: ProgressTracker,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress, defaultValue: 0),
            in: progressTracker.range,
            label: label,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        ) { isEditing in
            progressTracker.isInteracting = isEditing
        }
    }
}

@available(tvOS, unavailable)
public extension Slider where ValueLabel == EmptyView {
    /// Create a slider bound to a progress tracker.
    /// - Parameters:
    ///   - progressTracker: The progress tracker.
    ///   - label: A view describing the slider purpose.
    @MainActor
    init(progressTracker: ProgressTracker, @ViewBuilder label: () -> Label) {
        self.init(
            value: Binding(progressTracker, at: \.progress, defaultValue: 0),
            in: progressTracker.range,
            label: label
        ) { isEditing in
            progressTracker.isInteracting = isEditing
        }
    }
}

@available(tvOS, unavailable)
public extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    /// Create a slider bound to a progress tracker.
    /// - Parameters:
    ///   - progressTracker: The progress tracker.
    @MainActor
    init(progressTracker: ProgressTracker) {
        self.init(
            value: Binding(progressTracker, at: \.progress, defaultValue: 0),
            in: progressTracker.range
        ) { isEditing in
            progressTracker.isInteracting = isEditing
        }
    }
}
