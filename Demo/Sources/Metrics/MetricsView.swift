//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct MetricsView: View {
    let player: Player

    @StateObject private var metricsCollector = MetricsCollector(interval: .init(value: 1, timescale: 1))

    var body: some View {
        Chart {
            ForEach(Array(metricsCollector.metrics.enumerated()), id: \.offset) { metrics in
                if let observedBitrate = metrics.element.observedBitrate {
                    LineMark(
                        x: .value("Index", metrics.offset),
                        y: .value("Bandwidth (Mbps)", observedBitrate / 1_000_000),
                        series: .value("Mbps", "Bandwidth")
                    )
                }
            }
            ForEach(Array(metricsCollector.metrics.enumerated()), id: \.offset) { metrics in
                if let indicatedBitrate = metrics.element.indicatedBitrate {
                    LineMark(
                        x: .value("Index", metrics.offset),
                        y: .value("Indicated (Mbps)", indicatedBitrate / 1_000_000),
                        series: .value("Mbps", "Indicated")
                    )
                    .foregroundStyle(.red)
                }
            }
            ForEach(Array(metricsCollector.metrics.enumerated()), id: \.offset) { metrics in
                BarMark(
                    x: .value("Index", metrics.offset),
                    y: .value("Stalls", metrics.element.increment.numberOfMediaRequests)
                )
                .foregroundStyle(.yellow)
            }
        }
        .bind(metricsCollector, to: player)
    }
}

#Preview {
    MetricsView(player: .init(item: .urn("urn:rts:video:14968211")))
}
