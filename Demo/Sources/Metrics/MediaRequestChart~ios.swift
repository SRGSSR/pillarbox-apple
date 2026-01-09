//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

private struct MediaRequestChartPreview: View {
    @State private var player = Player(item: URLMedia.appleAdvanced_16_9_TS_HLS.item())
    @StateObject private var metricsCollector = MetricsCollector(interval: .init(value: 1, timescale: 1))

    var body: some View {
        MediaRequestChart(metrics: metricsCollector.metrics, limit: 100)
            .bind(metricsCollector, to: player)
            .onAppear(perform: player.play)
    }
}

struct MediaRequestChart: View {
    let metrics: [Metrics]
    let limit: Int

    var body: some View {
        chart()
        summary()
    }

    private var total: Int {
        metrics.last?.total.numberOfMediaRequests ?? 0
    }

    private func chart() -> some View {
        Chart(Array(metrics.suffix(limit).enumerated()), id: \.offset) { metrics in
            BarMark(
                x: .value("Index", metrics.offset),
                y: .value("Media requests", metrics.element.increment.numberOfMediaRequests),
                width: .inset(1)
            )
            .foregroundStyle(.yellow)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...limit - 1)
        .padding(.vertical)
    }

    private func summary() -> some View {
        Text("Total \(total)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    MediaRequestChartPreview()
}
