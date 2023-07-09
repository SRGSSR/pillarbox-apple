//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

#if os(iOS)
struct PlaybackSlider<ValueLabel: View>: View {
    let progressTracker: ProgressTracker
    let minimumValueLabel: () -> ValueLabel
    let maximumValueLabel: () -> ValueLabel

    @Binding private var value: Float
    @State private var valueWidth: CGFloat = 0
    @State private var previousValueWidth: CGFloat = 0

    @Binding private var buffer: Float
    @State private var bufferWidth: CGFloat = 0

    var body: some View {
        HStack {
            format(minimumValueLabel)
            progressBar(valueWidth: valueWidth, bufferWidth: bufferWidth)
            format(maximumValueLabel)
        }
        .frame(height: 10)
        .frame(maxWidth: .infinity)
    }

    init(
        progressTracker: ProgressTracker,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel
    ) {
        self.progressTracker = progressTracker
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
        _value = Binding(progressTracker, at: \.progress)
        _buffer = Binding(progressTracker, at: \.buffer)
    }

    @ViewBuilder
    private func format(_ label: () -> ValueLabel) -> some View {
        label()
            .font(.caption)
            .monospacedDigit()
    }

    @ViewBuilder
    private func rectangle(opacity: Double = 1, width: CGFloat? = nil) -> some View {
        Rectangle()
            .foregroundColor(.white)
            .opacity(opacity)
            .frame(width: width)
    }

    @ViewBuilder
    private func progressBar(valueWidth: CGFloat, bufferWidth: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                rectangle(opacity: 0.1)
                rectangle(opacity: 0.3, width: bufferWidth)
                rectangle(width: valueWidth)
            }
            .gesture(dragGesture(geometry: geometry))
            .onChange(of: value) { onValueChanged($0, geometry: geometry) }
            .onChange(of: buffer) { onBufferChanged($0, geometry: geometry) }
        }
        .cornerRadius(5)
        .scaleEffect(y: progressTracker.isInteracting ? 1.5 : 1.0)
        .animation(.smooth(duration: 0.4), value: progressTracker.isInteracting)
    }

    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                progressTracker.isInteracting = true
                let width = geometry.size.width
                let translation = gesture.translation.width
                valueWidth = (previousValueWidth + translation).clamped(to: 0...width)
                value = Float(valueWidth / width)
            }
            .onEnded { _ in
                progressTracker.isInteracting = false
                previousValueWidth = valueWidth
            }
    }

    func onValueChanged(_ value: Float, geometry: GeometryProxy) {
        let width = geometry.size.width
        valueWidth = CGFloat(value) * width
        if !progressTracker.isInteracting {
            previousValueWidth = valueWidth
        }
    }

    private func onBufferChanged(_ buffer: Float, geometry: GeometryProxy) {
        let width = geometry.size.width
        let widthToApply = CGFloat(buffer) * width
        if widthToApply.isNormal {
            bufferWidth = widthToApply
        }
    }
}

extension PlaybackSlider where ValueLabel == EmptyView {
    init(progressTracker: ProgressTracker) {
        self.init(progressTracker: progressTracker, minimumValueLabel: { EmptyView() }, maximumValueLabel: { EmptyView() })
    }
}

struct PlaybackSlider_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSlider(progressTracker: .init(interval: .zero))
            .padding(.horizontal, 5)
            .preferredColorScheme(.dark)
    }
}
#endif
