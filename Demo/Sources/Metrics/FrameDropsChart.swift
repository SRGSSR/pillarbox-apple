//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct FrameDropsChart: View {
    let metrics: [Metrics]
    let limit: Int

    var body: some View {
        chart()
        summary()
    }

    private var total: Int {
        metrics.last?.total.numberOfDroppedVideoFrames ?? 0
    }

    @ViewBuilder
    private func chart() -> some View {
        Chart(Array(metrics.suffix(limit).enumerated()), id: \.offset) { metrics in
            BarMark(
                x: .value("Index", metrics.offset),
                y: .value("Frame drops", metrics.element.increment.numberOfDroppedVideoFrames),
                width: .inset(1)
            )
            .foregroundStyle(.purple)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...limit - 1)
        .padding(.vertical)
    }

    @ViewBuilder
    private func summary() -> some View {
        Text("Total \(total)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
