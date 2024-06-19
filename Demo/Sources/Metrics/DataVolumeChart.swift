//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct DataVolumeChart: View {
    let metrics: [Metrics]
    let limit: Int

    private var bytesTransferred: String {
        ByteCountFormatStyle().format(metrics.last?.total.numberOfBytesTransferred ?? 0)
    }

    var body: some View {
        chart()
        summary()
    }

    @ViewBuilder
    private func chart() -> some View {
        Chart(Array(metrics.suffix(limit).enumerated()), id: \.offset) { metrics in
            BarMark(
                x: .value("Index", metrics.offset),
                y: .value("Data volume (MB)", metrics.element.increment.numberOfBytesTransferred / 1_000_000),
                width: .inset(1)
            )
            .foregroundStyle(.cyan)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...limit - 1)
        .chartYAxisLabel("MB")
        .padding(.vertical)
    }

    @ViewBuilder
    private func summary() -> some View {
        Text("Total \(bytesTransferred)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
