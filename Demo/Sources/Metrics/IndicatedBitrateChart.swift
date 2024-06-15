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
        Chart(Array(metrics.suffix(Self.maxX).enumerated()), id: \.offset) { metrics in
            if let indicatedBitrate = metrics.element.indicatedBitrate {
                LineMark(
                    x: .value("Index", metrics.offset),
                    y: .value("Indicated (Mbps)", indicatedBitrate / 1_000_000),
                    series: .value("Mbps", "Indicated")
                )
                .foregroundStyle(.red)
            }
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...Self.maxX - 1)
        .padding()
    }
}
