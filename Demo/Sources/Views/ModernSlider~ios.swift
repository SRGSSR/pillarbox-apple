//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct Highlight<V>: Hashable where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    let bounds: ClosedRange<V>
    let color: Color

    init(bounds: ClosedRange<V>, color: Color) {
        self.bounds = bounds.clamped(to: 0...1)
        self.color = color
    }
}

struct ModernSlider<V, ValueLabel>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint, ValueLabel: View {
    @Binding private var value: V
    private let bounds: ClosedRange<V>
    @State private var isInteracting = false
    let highlights: [Highlight<V>]

    private let minimumValueLabel: () -> ValueLabel
    private let maximumValueLabel: () -> ValueLabel
    private let onEditingChanged: (Bool) -> Void
    private let onDragging: () -> Void

    @GestureState private var gestureValue: DragGesture.Value?
    @State private var initialValue: V = 0

    var body: some View {
        HStack {
            minimumValueLabel()
            progressBar()
            maximumValueLabel()
        }
        .preventsTouchPropagation()
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($gestureValue) { value, state, _ in
                    state = value
                }
        )
        .frame(maxWidth: .infinity)
        .accessibilityRepresentation {
            Slider(
                value: $value,
                in: bounds,
                label: {
                    Text("Progress")
                },
                minimumValueLabel: minimumValueLabel,
                maximumValueLabel: maximumValueLabel
            )
        }
        .accessibilityAddTraits(.updatesFrequently)
    }

    init(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0...1,
        highlights: [Highlight<V>] = [],
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onDragging: @escaping () -> Void = {}
    ) {
        _value = value
        self.bounds = bounds
        self.highlights = highlights
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
        self.onEditingChanged = onEditingChanged
        self.onDragging = onDragging
    }

    @ViewBuilder
    private func rectangle(color: Color, width: CGFloat? = nil) -> some View {
        Rectangle()
            .foregroundColor(color)
            .frame(width: width)
    }

    @ViewBuilder
    private func progressBar() -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                rectangle(color: .white.opacity(0.1))
                    .background(.ultraThinMaterial)
                ForEach(highlights, id: \.self) { highlight in
                    rectangle(color: highlight.color, width: geometry.size.width * CGFloat(highlight.bounds.upperBound - highlight.bounds.lowerBound))
                        .offset(x: geometry.size.width * CGFloat(highlight.bounds.lowerBound))
                }
                rectangle(color: .white, width: geometry.size.width * CGFloat(value))
            }
            .onChange(of: gestureValue) { value in
                updateProgress(for: value, in: geometry)
            }
        }
        .frame(height: isInteracting ? 16 : 8)
        .clipShape(.capsule)
        .animation(.easeInOut(duration: 0.4), value: isInteracting)
        .frame(height: 30)
    }

    private func updateProgress(for value: DragGesture.Value?, in geometry: GeometryProxy) {
        if let value {
            onDragging()
            if !isInteracting {
                isInteracting = true
                initialValue = self.value
                onEditingChanged(true)
            }
            let delta = (geometry.size.width != 0) ? V(value.translation.width / geometry.size.width) : 0
            self.value = initialValue + delta
        }
        else {
            initialValue = 0
            isInteracting = false
            onEditingChanged(false)
        }
    }
}

extension ModernSlider where ValueLabel == EmptyView {
    init(value: Binding<V>, in bounds: ClosedRange<V> = 0...1) {
        self.init(value: value, in: bounds, minimumValueLabel: { EmptyView() }, maximumValueLabel: { EmptyView() })
    }
}

#Preview {
    ModernSlider(value: .constant(0.5))
        .padding(.horizontal, 5)
        .preferredColorScheme(.dark)
}
