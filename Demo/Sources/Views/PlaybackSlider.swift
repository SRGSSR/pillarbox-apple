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

    @State private var initialProgress: Float?

    var body: some View {
        HStack {
            format(minimumValueLabel)
            progressBar()
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
            .animation(.linear(duration: 0.2), values: progressTracker.buffer, progressTracker.progress)
            .gesture(dragGesture(in: geometry))
        }
        .cornerRadius(5)
        .scaleEffect(y: progressTracker.isInteracting ? 1.5 : 1.0)
        .animation(.smooth(duration: 0.4), value: progressTracker.isInteracting)
    }

    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                progressTracker.isInteracting = true
                if initialProgress == nil {
                    initialProgress = progressTracker.progress
                }
                if geometry.size.width != 0 {
                    progressTracker.progress = initialProgress! + Float(value.translation.width / geometry.size.width)
                }
                else {
                    progressTracker.progress = initialProgress!
                }
            }
            .onEnded { _ in
                initialProgress = nil
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
