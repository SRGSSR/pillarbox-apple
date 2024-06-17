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
        chart()
        summary()
    }

    private var currentIndicatedBitrateMbps: Double? {
        guard let currentMetrics = metrics.last else { return nil }
        return Self.indicatedBitrateMbps(from: currentMetrics)
    }

    private var minIndicatedBitrateMbps: Double? {
        guard let max = metrics.compactMap(\.indicatedBitrate).min() else { return nil }
        return max / 1_000_000
    }

    private var maxIndicatedBitrateMbps: Double? {
        guard let max = metrics.compactMap(\.indicatedBitrate).max() else { return nil }
        return max / 1_000_000
    }

    private static func indicatedBitrateMbps(from metrics: Metrics) -> Double? {
        guard let value = metrics.indicatedBitrate else { return nil }
        return value / 1_000_000
    }

    @ViewBuilder
    private func chart() -> some View {
        Chart(Array(metrics.suffix(Self.maxX).enumerated()), id: \.offset) { metrics in
            if let indicatedBitrate = Self.indicatedBitrateMbps(from: metrics.element) {
                LineMark(
                    x: .value("Index", metrics.offset),
                    y: .value("Indicated bitrate (Mbps)", indicatedBitrate),
                    series: .value("Mbps", "Indicated bitrate")
                )
                .foregroundStyle(.red)
            }
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...Self.maxX - 1)
        .chartYAxisLabel("Mbps")
        .padding(.vertical)
    }

    @ViewBuilder
    private func summary() -> some View {
        HStack {
            if let minIndicatedBitrateMbps {
                Text("Min. \(minIndicatedBitrateMbps, specifier: "%.02f") Mbps")
            }
            if let currentIndicatedBitrateMbps {
                Text("Curr. \(currentIndicatedBitrateMbps, specifier: "%.02f") Mbps")
            }
            if let maxIndicatedBitrateMbps {
                Text("Max. \(maxIndicatedBitrateMbps, specifier: "%.02f") Mbps")
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
