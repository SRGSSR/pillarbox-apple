//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A horizontal control for selecting a value from a bounded linear range of values.
struct HSlider<Value, Content>: View where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint, Content: View {
    @Binding private var value: Value
    @Binding private var scrubbingSpeed: Double

    private let bounds: ClosedRange<Value>
    private let content: (CGFloat, CGFloat) -> Content

    fileprivate var onEditingChanged: (_ isEditing: Bool) -> Void = { _ in }
    fileprivate var onDragging: () -> Void = {}
    fileprivate var updatingScrubbingSpeedBody: (_ yDistance: CGFloat) -> Double = { _ in 1 }

    @State private var isInteracting = false

    @GestureState private var gestureValue: DragGesture.Value?
    @State private var previousGestureValue: DragGesture.Value?

    private var progress: Double {
        guard !bounds.isEmpty else { return 0 }
        return Self.progress(for: value, in: bounds)
    }

    var body: some View {
        GeometryReader { geometry in
            content(.init(progress), geometry.size.width)
                // Use center alignment instead of top leading alignment used by `GeometryReader`.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .gesture(dragGesture(in: geometry))
                .onChange(of: gestureValue) { value in
                    // Gesture cancellation can only be detected via gesture value observation,
                    // see https://developer.apple.com/documentation/swiftui/adding-interactivity-with-gestures#Update-transient-UI-state
                    if value == nil {
                        onEnded()
                    }
                }
        }
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
        self._scrubbingSpeed = .constant(1)
        self.bounds = bounds
        self.content = content
    }

    private static func value(for progress: Double, in bounds: ClosedRange<Value>) -> Value {
        (Value(progress) * (bounds.upperBound - bounds.lowerBound) + bounds.lowerBound).clamped(to: bounds)
    }

    private static func progress(for value: Value, in bounds: ClosedRange<Value>) -> Double {
        .init((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)).clamped(to: 0...1)
    }

    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($gestureValue) { value, state, _ in
                previousGestureValue = state
                state = value
            }
            .onChanged { value in
                onChanged(with: value, in: geometry)
            }
            .onEnded { value in
                onChanged(with: value, in: geometry)
                onEnded()
            }
    }

    private func onChanged(with gestureValue: DragGesture.Value, in geometry: GeometryProxy) {
        onDragging()
        if !isInteracting {
            isInteracting = true
            onEditingChanged(true)
        }
        let xTranslation = gestureValue.translation.width - (previousGestureValue?.translation.width ?? 0)
        let scrubbingSpeed = scrubbingSpeed(for: gestureValue)
        let progress = Self.progress(for: value, in: bounds) + xTranslation / geometry.size.width * scrubbingSpeed
        self.value = Self.value(for: progress, in: bounds)
        self.scrubbingSpeed = scrubbingSpeed
    }

    private func onEnded() {
        guard isInteracting else { return }
        isInteracting = false
        previousGestureValue = nil
        onEditingChanged(false)
    }

    private func scrubbingSpeed(for gestureValue: DragGesture.Value?) -> Double {
        guard let gestureValue else { return 1 }
        return updatingScrubbingSpeedBody(abs(gestureValue.translation.height))
    }
}

extension HSlider {
    /// Adds an action to perform when editing begins or ends.
    func onEditingChanged(_ action: @escaping (_ isEditing: Bool) -> Void) -> Self {
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

    /// Allows scrubbing speed adjustments based on distance to the slider.
    func updatingScrubbingSpeed(_ scrubbingSpeed: Binding<Double>, body: @escaping (_ yDistance: CGFloat) -> Double) -> Self {
        var slider = self
        slider._scrubbingSpeed = scrubbingSpeed
        slider.updatingScrubbingSpeedBody = body
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
