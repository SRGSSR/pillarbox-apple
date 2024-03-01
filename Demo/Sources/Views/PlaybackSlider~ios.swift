//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct PlaybackSlider<ValueLabel>: View where ValueLabel: View {
    @ObservedObject var progressTracker: ProgressTracker

    let minimumValueLabel: () -> ValueLabel
    let maximumValueLabel: () -> ValueLabel
    let onEditingChanged: (Bool) -> Void
    let onDragging: () -> Void
    let forbiddenRanges: [ClosedRange<Float>]

    @GestureState private var gestureValue: DragGesture.Value?
    @State private var initialProgress: Float = 0
    @State private var buffer: Float = 0

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
        .onReceive(player: progressTracker.player, assign: \.buffer, to: $buffer)
    }

    init(
        progressTracker: ProgressTracker,
        @ViewBuilder minimumValueLabel: @escaping () -> ValueLabel,
        @ViewBuilder maximumValueLabel: @escaping () -> ValueLabel,
        forbiddenRanges: [ClosedRange<Float>] = [],
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onDragging: @escaping () -> Void = {}
    ) {
        self.progressTracker = progressTracker
        self.minimumValueLabel = minimumValueLabel
        self.maximumValueLabel = maximumValueLabel
        self.forbiddenRanges = forbiddenRanges
        self.onEditingChanged = onEditingChanged
        self.onDragging = onDragging
    }

    @ViewBuilder
    private func rectangle(opacity: Double = 1, width: CGFloat? = nil, color: Color = .white) -> some View {
        Rectangle()
            .foregroundColor(color)
            .opacity(opacity)
            .frame(width: width)
    }

    @ViewBuilder
    private func progressBar() -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                rectangle(opacity: 0.1)
                    .background(.ultraThinMaterial)
                rectangle(opacity: 0.3, width: geometry.size.width * CGFloat(buffer))
                    .animation(.linear(duration: 0.5), value: buffer)
                rectangle(width: geometry.size.width * CGFloat(progressTracker.progress))
                ForEach(forbiddenRanges, id: \.self) { range in
                    addForbidden(range: range, width: geometry.size.width)
                }
            }
            .onChange(of: gestureValue) { value in
                updateProgress(for: value, in: geometry)
            }
        }
        .frame(height: progressTracker.isInteracting ? 16 : 8)
        .clipShape(.capsule)
        .animation(.easeInOut(duration: 0.4), value: progressTracker.isInteracting)
        .frame(height: 30)
    }

    private func updateProgress(for value: DragGesture.Value?, in geometry: GeometryProxy) {
        if let value {
            onDragging()
            if !progressTracker.isInteracting {
                progressTracker.isInteracting = true
                initialProgress = progressTracker.progress
                onEditingChanged(true)
            }
            let delta = (geometry.size.width != 0) ? Float(value.translation.width / geometry.size.width) : 0
            progressTracker.progress = initialProgress + delta
        }
        else {
            initialProgress = 0
            progressTracker.isInteracting = false
            onEditingChanged(false)
        }
    }

    @ViewBuilder
    private func addForbidden(range: ClosedRange<Float>, width: CGFloat, color: Color = .red) -> some View {
        if let duration = progressTracker.timeRange?.duration.seconds {
            rectangle(opacity: 0.7, width: width * CGFloat(range.upperBound - range.lowerBound) / CGFloat(duration), color: .red)
                .offset(x: width * CGFloat(range.lowerBound) / CGFloat(duration))
        }
    }
}

extension PlaybackSlider where ValueLabel == EmptyView {
    init(progressTracker: ProgressTracker) {
        self.init(progressTracker: progressTracker, minimumValueLabel: { EmptyView() }, maximumValueLabel: { EmptyView() })
    }
}

#Preview {
    PlaybackSlider(progressTracker: .init(interval: .zero))
        .padding(.horizontal, 5)
        .preferredColorScheme(.dark)
}
