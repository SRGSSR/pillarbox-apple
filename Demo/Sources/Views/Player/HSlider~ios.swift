//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct DragGestureState: Equatable {
    let current: DragGesture.Value
    let previous: DragGesture.Value?

    var xTranslation: CGFloat {
        current.translation.width - (previous?.translation.width ?? 0)
    }
}

/// A horizontal control for selecting a value from a bounded linear range of values.
struct HSlider<Value, Content, Speed>: View where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint, Content: View, Speed: HSliderScrubbingSpeed {
    @Binding private var value: Value
    @Binding private var scrubbingSpeed: Speed

    private let bounds: ClosedRange<Value>
    private let content: (CGFloat, CGFloat) -> Content

    fileprivate var onEditingChanged: (_ isEditing: Bool) -> Void = { _ in }
    fileprivate var onDragging: () -> Void = {}

    @State private var isInteracting = false
    @GestureState private var gestureState: DragGestureState?

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
                .onChange(of: gestureState) { state in
                    // Gesture cancellation can only be detected via gesture value observation,
                    // see https://developer.apple.com/documentation/swiftui/adding-interactivity-with-gestures#Update-transient-UI-state
                    if state == nil {
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
    ///   - scrubbingSpeed: A binding to a scrubbing speed.
    ///   - content: A view that displays the progress (a value in `0...1`) corresponding to the current value within
    ///     `bounds`. The width of view to draw in is provided as parameter.
    init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        scrubbingSpeed: Binding<Speed>,
        @ViewBuilder content: @escaping (_ progress: CGFloat, _ width: CGFloat) -> Content
    ) {
        self._value = value
        self._scrubbingSpeed = scrubbingSpeed
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
            .updating($gestureState) { value, state, _ in
                state = .init(current: value, previous: state?.current)
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
        guard let gestureState else { return }
        onDragging()
        if !isInteracting {
            isInteracting = true
            onEditingChanged(true)
        }
        let scrubbingSpeed = scrubbingSpeed(for: gestureValue)
        let progress = Self.progress(for: value, in: bounds) + max(scrubbingSpeed.value, .leastNonzeroMagnitude) * gestureState.xTranslation / geometry.size.width
        self.value = Self.value(for: progress, in: bounds)
        self.scrubbingSpeed = scrubbingSpeed
    }

    private func onEnded() {
        guard isInteracting else { return }
        isInteracting = false
        scrubbingSpeed = .default
        onEditingChanged(false)
    }

    private func scrubbingSpeed(for gestureValue: DragGesture.Value?) -> Speed {
        guard let gestureValue else { return Speed.default }
        return Speed.speed(forDistance: abs(gestureValue.translation.height))
    }
}

extension HSlider where Speed == StandardScrubbingSpeed {
    init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        @ViewBuilder content: @escaping (_ progress: CGFloat, _ width: CGFloat) -> Content
    ) {
        self.init(value: value, in: bounds, scrubbingSpeed: .constant(.default), content: content)
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
