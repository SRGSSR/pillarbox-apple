//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct MetricsView: View {
    private static let limit = 90

    @ObservedObject var metricsCollector: MetricsCollector

    var body: some View {
        Group {
            if !metrics.isEmpty {
                List {
                    if let currentMetrics = metrics.last {
                        MetricsInfoView(metrics: currentMetrics, metricEvents: metricsCollector.metricEvents)
                    }
                    indicatedBitrateSection()
                    observedBitrateSection()
                    dataVolumeSection()
                    mediaRequestsSection()
                    stallsSection()
                    frameDropsSection()
                }
            }
            else {
                MessageView(message: "No metrics", icon: .system("chart.bar"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Metrics")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }

    private var metrics: [Metrics] {
        metricsCollector.metrics
    }

    private var currentMetrics: Metrics? {
        metrics.last
    }

    private func indicatedBitrateSection() -> some View {
        Section {
            IndicatedBitrateChart(metrics: metrics, limit: Self.limit)
        } header: {
            Text("Indicated bitrate")
        }
    }

    private func observedBitrateSection() -> some View {
        Section {
            ObservedBitrateChart(metrics: metrics, limit: Self.limit)
        } header: {
            Text("Observed bitrate")
        }
    }

    private func dataVolumeSection() -> some View {
        Section {
            DataVolumeChart(metrics: metrics, limit: Self.limit)
        } header: {
            Text("Data volume")
        }
    }

    private func mediaRequestsSection() -> some View {
        Section {
            MediaRequestChart(metrics: metrics, limit: Self.limit)
        } header: {
            Text("Media requests")
        }
    }

    private func stallsSection() -> some View {
        Section {
            StallsChart(metrics: metrics, limit: Self.limit)
        } header: {
            Text("Stalls")
        }
    }

    private func frameDropsSection() -> some View {
        Section {
            FrameDropsChart(metrics: metrics, limit: Self.limit)
        } header: {
            Text("Frame drops")
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    private struct MetricsPreview: View {
        @State private var player = Player(item: Media(from: URLTemplate.appleAdvanced_16_9_TS_HLS).playerItem())
        @StateObject private var metricsCollector = MetricsCollector(interval: .init(value: 1, timescale: 1))

        var body: some View {
            MetricsView(metricsCollector: metricsCollector)
                .bind(metricsCollector, to: player)
                .onAppear(perform: player.play)
        }
    }

    static var previews: some View {
        MetricsPreview()
    }
}
