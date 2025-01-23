//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A horizontal control for selecting a value from a bounded linear range of values.
struct HSlider<Value, Content>: View where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint, Content: View {
    @Binding private var value: Value
    private let bounds: ClosedRange<Value>
    private let content: (CGFloat, CGFloat) -> Content

    fileprivate var onEditingChanged: (Bool) -> Void = { _ in }
    fileprivate var onDragging: () -> Void = {}

    @State private var isInteracting = false
    @State private var initialProgress: Value = 0
    @GestureState private var gestureValue: DragGesture.Value?

    private var progress: Value {
        guard !bounds.isEmpty else { return 0 }
        return Self.progress(for: value, in: bounds)
    }

    var body: some View {
        GeometryReader { geometry in
            content(.init(progress), geometry.size.width)
                // Use center alignment instead of top leading alignment used by `GeometryReader`.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: gestureValue) { value in
                    update(for: value, in: geometry)
                }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($gestureValue) { value, state, _ in
                    state = value
                }
        )
    }

    /// Creates a slider to select a value from a given range.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - content: A view that displays the progress (a value in `0...1`) corresponding to the current value within
    ///     `bounds`. The width of view to draw in is provided as parameter.
    init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        @ViewBuilder content: @escaping (_ progress: CGFloat, _ width: CGFloat) -> Content
    ) {
        self._value = value
        self.bounds = bounds
        self.content = content
    }

    private static func value(for progress: Value, in bounds: ClosedRange<Value>) -> Value {
        (progress * (bounds.upperBound - bounds.lowerBound) + bounds.lowerBound).clamped(to: bounds)
    }

    private static func progress(for value: Value, in bounds: ClosedRange<Value>) -> Value {
        ((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)).clamped(to: bounds)
    }

    private func update(for value: DragGesture.Value?, in geometry: GeometryProxy) {
        if let value {
            onDragging()
            if !isInteracting {
                isInteracting = true
                initialProgress = progress
                onEditingChanged(true)
            }
            let delta = (geometry.size.width != 0) ? Value(value.translation.width / geometry.size.width) : 0
            self.value = Self.value(for: initialProgress + delta, in: bounds)
        }
        else {
            initialProgress = 0
            isInteracting = false
            onEditingChanged(false)
        }
    }
}

extension HSlider {
    /// Adds an action to perform when editing begins or ends.
    func onEditingChanged(_ action: @escaping (Bool) -> Void) -> Self {
        var slider = self
        slider.onEditingChanged = action
        return slider
    }

    /// Adds an action to perform when the user is dragging the slider.
    func onDragging(_ action: @escaping () -> Void) -> Self {
        var slider = self
        slider.onDragging = action
        return slider
    }
}

#Preview {
    HSlider(value: .constant(0.5)) { progress, width in
        Rectangle()
            .foregroundColor(.white)
            .frame(width: progress * width)
    }
    .background(.white.opacity(0.3))
    .frame(height: 30)
    .padding(.horizontal)
    .preferredColorScheme(.dark)
}
