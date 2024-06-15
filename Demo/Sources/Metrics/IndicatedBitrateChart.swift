//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct IndicatedBitrateChart: View {
    private static let maxX = 120

    let metrics: [Metrics]

    var body: some View {
        VStack {
            title()
            chart()
        }
        .padding()
    }

    @ViewBuilder
    private func title() -> some View {
        Text("Indicated bitrate (Mbps)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func chart() -> some View {
        Chart(Array(metrics.suffix(Self.maxX).enumerated()), id: \.offset) { metrics in
            if let indicatedBitrate = metrics.element.indicatedBitrate {
                LineMark(
                    x: .value("Index", metrics.offset),
                    y: .value("Indicated bitrate (Mbps)", indicatedBitrate / 1_000_000),
                    series: .value("Mbps", "Indicated bitrate")
                )
                .foregroundStyle(.red)
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
