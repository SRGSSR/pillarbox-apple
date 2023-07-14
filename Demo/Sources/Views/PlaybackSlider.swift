//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

#if os(iOS)
struct PlaybackSlider<ValueLabel: View>: View {
    @ObservedObject var progressTracker: ProgressTracker

    let minimumValueLabel: () -> ValueLabel
    let maximumValueLabel: () -> ValueLabel

    @State private var initialProgress: Float = 0

    var body: some View {
        HStack {
            format(minimumValueLabel)
            progressBar()
            format(maximumValueLabel)
        }
        .frame(height: 8)
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
    private func progressBar() -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                rectangle(opacity: 0.1)
                rectangle(opacity: 0.3, width: geometry.size.width * CGFloat(progressTracker.buffer))
                rectangle(width: geometry.size.width * CGFloat(progressTracker.progress))
            }
            .animation(.linear(duration: 0.5), value: progressTracker.buffer)
            .gesture(dragGesture(in: geometry))
        }
        .frame(height: progressTracker.isInteracting ? 16 : 8)
        .cornerRadius(progressTracker.isInteracting ? 8 : 4)
        .animation(.smooth(duration: 0.4), value: progressTracker.isInteracting)
    }

    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !progressTracker.isInteracting {
                    progressTracker.isInteracting = true
                    initialProgress = progressTracker.progress
                }
                let delta = (geometry.size.width != 0) ? Float(value.translation.width / geometry.size.width) : 0
                progressTracker.progress = initialProgress + delta
            }
            .onEnded { _ in
                initialProgress = 0
                progressTracker.isInteracting = false
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
