//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct ObservedBitrateChart: View {
    private static let maxX = 120

    let metrics: [Metrics]

    var body: some View {
        VStack {
            title()
            chart()
        }
        .padding()
    }

    private static func observedBitrateMbps(from metrics: Metrics) -> Double? {
        guard let value = metrics.observedBitrate else { return nil }
        return value / 1_000_000
    }

    private static func observedBitrateStandardDeviationMbps(from metrics: Metrics) -> Double? {
        guard let value = metrics.observedBitrateStandardDeviation else { return nil }
        return value / 1_000_000
    }

    @ViewBuilder
    private func title() -> some View {
        Text("Observed bitrate (Mbps)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func chart() -> some View {
        Chart(Array(metrics.suffix(Self.maxX).enumerated()), id: \.offset) { metrics in
            if let observedBitrate = Self.observedBitrateMbps(from: metrics.element) {
                LineMark(
                    x: .value("Index", metrics.offset),
                    y: .value("Observed bitrate (Mbps)", observedBitrate),
                    series: .value("Mbps", "Observed bitrate")
                )
                .foregroundStyle(.blue)

                if let observedBitrateStandardDeviation = Self.observedBitrateStandardDeviationMbps(from: metrics.element) {
                    AreaMark(
                        x: .value("Index", metrics.offset),
                        yStart: .value("Observed bitrate min", observedBitrate - observedBitrateStandardDeviation / 2),
                        yEnd: .value("Observed bitrate max", observedBitrate + observedBitrateStandardDeviation / 2)
                    )
                    .opacity(0.3)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...Self.maxX - 1)
        .chartYAxis {
            AxisMarks(position: .leading)
            AxisMarks(position: .trailing)
        }
    }
}
