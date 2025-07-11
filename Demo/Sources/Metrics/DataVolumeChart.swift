//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct DataVolumeChart: View {
    private static let megabytes = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        return formatter.string(from: UnitInformationStorage.megabytes)
    }()

    let metrics: [Metrics]
    let limit: Int

    var body: some View {
        chart()
        summary()
    }

    private var bytesTransferred: String {
        ByteCountFormatStyle().format(metrics.last?.total.numberOfBytesTransferred ?? 0)
    }

    private func chart() -> some View {
        Chart(Array(metrics.suffix(limit).enumerated()), id: \.offset) { metrics in
            BarMark(
                x: .value("Index", metrics.offset),
                y: .value("Data volume (\(Self.megabytes)", Double(metrics.element.increment.numberOfBytesTransferred) / 1024 / 1024),
                width: .inset(1)
            )
            .foregroundStyle(.cyan)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...limit - 1)
        .chartYAxisLabel(Self.megabytes)
        .padding(.vertical)
    }

    private func summary() -> some View {
        Text("Total \(bytesTransferred)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
