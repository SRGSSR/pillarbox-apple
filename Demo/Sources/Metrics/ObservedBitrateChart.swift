//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct ObservedBitrateChart: View {
    let metrics: [Metrics]

    var body: some View {
        Chart {
            ForEach(Array(metrics.enumerated()), id: \.offset) { metrics in
                if let observedBitrate = metrics.element.observedBitrate {
                    LineMark(
                        x: .value("Index", metrics.offset),
                        y: .value("Bandwidth (Mbps)", observedBitrate / 1_000_000),
                        series: .value("Mbps", "Bandwidth")
                    )
                }
            }
            .foregroundStyle(.blue)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
