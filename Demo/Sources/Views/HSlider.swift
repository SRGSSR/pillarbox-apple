//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct HSlider<Value, Content>: View where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint, Content: View {
    @Binding private var value: Value
    private let bounds: ClosedRange<Value>
    private let content: (CGFloat, CGFloat) -> Content

    fileprivate var onEditingChanged: (Bool) -> Void = { _ in }
    fileprivate var onDragging: () -> Void = {}

    @State private var isInteracting = false
    @State private var initialValue: Value = 0
    @GestureState private var gestureValue: DragGesture.Value?

    var body: some View {
        GeometryReader { geometry in
            content(.init(value), geometry.size.width)
                // Use center alignment instead of top leading alignment used by `GeometryReader`.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: gestureValue) { value in
                    updateProgress(for: value, in: geometry)
                }
        }
        .preventsTouchPropagation()
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($gestureValue) { value, state, _ in
                    state = value
                }
        )
    }

    init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        @ViewBuilder content: @escaping (_ progress: CGFloat, _ width: CGFloat) -> Content
    ) {
        self._value = value
        self.bounds = bounds
        self.content = content
    }

    private func updateProgress(for value: DragGesture.Value?, in geometry: GeometryProxy) {
        if let value {
            onDragging()
            if !isInteracting {
                isInteracting = true
                initialValue = self.value
                onEditingChanged(true)
            }
            let delta = (geometry.size.width != 0) ? Value(value.translation.width / geometry.size.width) : 0
            self.value = initialValue + delta
        }
        else {
            initialValue = 0
            isInteracting = false
            onEditingChanged(false)
        }
    }
}

extension HSlider {
    func onEditingChanged(_ action: @escaping (Bool) -> Void) -> Self {
        var slider = self
        slider.onEditingChanged = action
        return slider
    }

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
