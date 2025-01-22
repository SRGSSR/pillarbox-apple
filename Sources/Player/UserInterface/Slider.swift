//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS 16, *)
@available(tvOS, unavailable)
public extension Slider {
    /// Creates a slider bound to a progress tracker.
    ///
    /// - Parameters:
    ///   - progressTracker: The progress tracker.
    ///   - label: A view describing the slider purpose.
    ///   - minimumValueLabel: A view describing the lower bound.
    ///   - maximumValueLabel: A view describing the upper bound.
    ///   - onEditingChanged: A closure called when editing begins or ends.
    init(
        progressTracker: ProgressTracker,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress),
            in: progressTracker.range,
            label: label,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        ) { isEditing in
            progressTracker.isInteracting = isEditing
            onEditingChanged(isEditing)
        }
    }
}

@available(iOS 16, *)
@available(tvOS, unavailable)
public extension Slider where ValueLabel == EmptyView {
    /// Creates a slider bound to a progress tracker.
    ///
    /// - Parameters:
    ///   - progressTracker: The progress tracker.
    ///   - label: A view describing the slider purpose.
    ///   - onEditingChanged: A closure called when editing begins or ends.
    init(
        progressTracker: ProgressTracker,
        @ViewBuilder label: () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress),
            in: progressTracker.range,
            label: label
        ) { isEditing in
            progressTracker.isInteracting = isEditing
            onEditingChanged(isEditing)
        }
    }
}

@available(iOS 16, *)
@available(tvOS, unavailable)
public extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    /// Creates a slider bound to a progress tracker.
    /// 
    /// - Parameters:
    ///   - progressTracker: The progress tracker.
    ///   - onEditingChanged: A closure called when editing begins or ends.
    init(
        progressTracker: ProgressTracker,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress),
            in: progressTracker.range
        ) { isEditing in
            progressTracker.isInteracting = isEditing
            onEditingChanged(isEditing)
        }
    }
}
