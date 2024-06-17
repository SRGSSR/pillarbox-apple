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
                List {
                    if let currentMetrics = metrics.last {
                        MetricsInfoView(metrics: currentMetrics)
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private func indicatedBitrateSection() -> some View {
        Section {
            IndicatedBitrateChart(metrics: metrics)
        } header: {
            Text("Indicated bitrate")
        }
    }

    private func observedBitrateSection() -> some View {
        Section {
            ObservedBitrateChart(metrics: metrics)
        } header: {
            Text("Observed bitrate")
        }
    }

    private func dataVolumeSection() -> some View {
        Section {
            DataVolumeChart(metrics: metrics)
        } header: {
            Text("Data volume")
        }
    }

    private func mediaRequestsSection() -> some View {
        Section {
            MediaRequestChart(metrics: metrics)
        } header: {
            Text("Media requests")
        }
    }

    private func stallsSection() -> some View {
        Section {
            StallsChart(metrics: metrics)
        } header: {
            Text("Stalls")
        }
    }

    private func frameDropsSection() -> some View {
        Section {
            FrameDropsChart(metrics: metrics)
        } header: {
            Text("Frame drops")
        }
    }
}
