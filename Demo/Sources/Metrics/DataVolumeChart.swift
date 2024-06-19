//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct DataVolumeChart: View {
    private static let maxX = 90

    let metrics: [Metrics]

    var body: some View {
        Chart(Array(metrics.suffix(Self.maxX).enumerated()), id: \.offset) { metrics in
            BarMark(
                x: .value("Index", metrics.offset),
                y: .value("Data volume (MB)", metrics.element.increment.numberOfBytesTransferred / 1_000_000),
                width: .inset(1)
            )
            .foregroundStyle(.cyan)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...Self.maxX - 1)
        .chartYAxisLabel("MB")
        .padding(.vertical)
    }
}
