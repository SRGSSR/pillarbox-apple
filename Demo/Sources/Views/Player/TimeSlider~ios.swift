//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

struct TimeSlider: View {
    private static let shortFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let longFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let timeFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var visibilityTracker: VisibilityTracker
    @State private var streamType: StreamType = .unknown
    @State private var buffer: Float = 0

    private var formattedElapsedTime: String? {
        if streamType == .onDemand {
            return Self.formattedTime((progressTracker.time - progressTracker.timeRange.start), duration: progressTracker.timeRange.duration)
        }
        else if let date = progressTracker.date() {
            return Self.timeFormatter.string(from: date)
        }
        else {
            return nil
        }
    }

    private var formattedTotalTime: String? {
        guard streamType == .onDemand else { return nil }
        return Self.formattedTime(progressTracker.timeRange.duration, duration: progressTracker.timeRange.duration)
    }

    private var isVisible: Bool {
        progressTracker.isProgressAvailable && streamType != .unknown
    }

    var body: some View {
        HStack {
            label(withText: formattedElapsedTime)
            slider()
            label(withText: formattedTotalTime)
        }
        .frame(height: 30)
        .accessibilityRepresentation {
            Slider(
                progressTracker: progressTracker,
                label: {
                    Text("Current position")
                },
                minimumValueLabel: {
                    label(withText: formattedElapsedTime)
                },
                maximumValueLabel: {
                    label(withText: formattedTotalTime)
                }
            )
        }
        .accessibilityAddTraits(.updatesFrequently)
        ._debugBodyCounter(color: .blue)
        .onReceive(player: player, assign: \.streamType, to: $streamType)
        .onReceive(player: player, assign: \.buffer, to: $buffer)
    }

    private static func formattedTime(_ time: CMTime, duration: CMTime) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatter.string(from: time.seconds)!
        }
        else {
            return longFormatter.string(from: time.seconds)!
        }
    }

    private static func color(for timeRange: TimeRange) -> Color {
        switch timeRange.kind {
        case .credits:
            return .orange
        case .blocked:
            return .red
        }
    }

    private func slider() -> some View {
        HSlider(value: $progressTracker.progress) { progress, width in
            ZStack(alignment: .leading) {
                sliderBackground()
                sliderTimeRanges(width: width)
                sliderBuffer(width: width)
                sliderTrack(progress: progress, width: width)
            }
            .frame(height: progressTracker.isInteracting ? 16 : 8)
            .clipShape(.capsule)
            .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
            .opacity(isVisible ? 1 : 0)
            .animation(.defaultLinear, value: progressTracker.isInteracting)
        }
        .onEditingChanged { isEditing in
            progressTracker.isInteracting = isEditing
        }
        .onDragging(visibilityTracker.reset)
    }

    private func sliderBackground() -> some View {
        Color.white
            .opacity(0.1)
            .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func sliderTimeRanges(width: CGFloat) -> some View {
        if progressTracker.timeRange.isValid {
            let duration = progressTracker.timeRange.duration.seconds
            ForEach(player.metadata.timeRanges, id: \.self) { timeRange in
                Self.color(for: timeRange)
                    .opacity(0.7)
                    .frame(width: width * CGFloat(timeRange.duration.seconds / duration))
                    .offset(x: width * CGFloat(timeRange.start.seconds / duration))
            }
        }
    }

    private func sliderBuffer(width: CGFloat) -> some View {
        Color.white
            .opacity(0.3)
            .frame(width: CGFloat(buffer) * width)
            .animation(.defaultLinear, value: buffer)
    }

    private func sliderTrack(progress: CGFloat, width: CGFloat) -> some View {
        Color.white
            .frame(width: progress * width)
    }

    @ViewBuilder
    private func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.white)
                .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
        }
    }
}
