//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct MetricsView: View {
    @ObservedObject var metricsCollector = MetricsCollector(interval: .init(value: 1, timescale: 1))

    private var metrics: [Metrics] {
        metricsCollector.metrics
    }

    private var currentMetrics: Metrics? {
        metrics.last
    }

    var body: some View {
        Group {
            if !metrics.isEmpty {
                ScrollView {
                    VStack {
                        if let currentMetrics = metrics.last {
                            MetricsInfoView(metrics: currentMetrics)
                        }
                        IndicatedBitrateChart(metrics: metrics)
                        ObservedBitrateChart(metrics: metrics)
                        MediaRequestChart(metrics: metrics)
                    }
                    .padding(.vertical)
                }
            }
            else {
                MessageView(message: "No metrics", icon: .empty)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Metrics")
        .navigationBarTitleDisplayMode(.inline)
    }
}
