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

    var body: some View {
        if !metrics.isEmpty {
            ScrollView {
                VStack {
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
}
