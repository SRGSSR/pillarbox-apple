//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct PlaybackSlider: View {
    let progressTracker: ProgressTracker
    let minimumValueText: String = ""
    let maximumValueText: String = ""

    @Binding private var value: Float
    @State private var valueWidth: CGFloat = 0
    @State private var previousValueWidth: CGFloat = 0

    @Binding private var buffer: Float
    @State private var bufferWidth: CGFloat = 0

    @State private var isDragging = false {
        didSet {
            progressTracker.isInteracting = isDragging
        }
    }

    var body: some View {
        HStack {
            text(minimumValueText)
            progressBar(valueWidth: valueWidth, bufferWidth: bufferWidth)
            text(maximumValueText)
        }
    }

    init(progressTracker: ProgressTracker) {
        self.progressTracker = progressTracker
        _value = Binding(progressTracker, at: \.progress)
        _buffer = Binding(progressTracker, at: \.loaded)
    }

    @ViewBuilder
    private func text(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .fixedSize()
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
    }

    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                isDragging = true
                let width = geometry.size.width
                let translation = gesture.translation.width
                valueWidth = (previousValueWidth + translation).clamped(to: 0...width)
                value = Float(valueWidth / width)
            }
            .onEnded { _ in
                isDragging = false
                previousValueWidth = valueWidth
            }
    }

    func onValueChanged(_ value: Float, geometry: GeometryProxy) {
        let width = geometry.size.width
        valueWidth = CGFloat(value) * width
        if !isDragging {
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

struct PlaybackSlider_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSlider(progressTracker: .init(interval: .zero))
            .padding(.horizontal, 5)
    }
}
