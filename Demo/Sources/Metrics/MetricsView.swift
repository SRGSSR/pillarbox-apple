//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

private struct InformationSectionContent: View {
    private static let dateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    let metrics: Metrics

    var body: some View {
        cell("URI", value: uri)
#if os(iOS)
            .swipeActions { CopyButton(text: uri) }
#endif
        cell("Type", value: metrics.playbackType ?? "-")
        cell("Playback duration", value: playbackDuration)
        cell("Data volume", value: bytesTransferred)
    }

    private var uri: String {
        metrics.uri ?? "-"
    }

    private var playbackDuration: String {
        Self.dateComponentsFormatter.string(from: metrics.total.playbackDuration) ?? "-"
    }

    private var bytesTransferred: String {
        ByteCountFormatStyle().format(metrics.total.numberOfBytesTransferred)
    }

    private func cell(_ name: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
                .monospacedDigit()
                .lineLimit(1)
                .foregroundColor(.secondary)
        }
    }
}

private struct StartupTimesSectionContent: View {
    let metrics: Metrics
    let metricEvents: [MetricEvent]

    var body: some View {
        cell("Asset loading", value: assetLoadingDuration)
        cell("Resource loading", value: resourceLoadingDuration)
        cell("Initial buffering", value: startupTime)
    }

    private var startupTime: String {
        guard let startupTime = metrics.startupTime else { return "-" }
        return String(format: "%.6fs", startupTime)
    }

    private var assetLoadingInterval: TimeInterval? {
        metricEvents.compactMap { event in
            switch event.kind {
            case let .assetLoading(interval):
                return interval.duration
            default:
                return nil
            }
        }.first        // First asset loading event
    }

    private var resourceLoadingInterval: TimeInterval? {
        metricEvents.compactMap { event in
            switch event.kind {
            case let .resourceLoading(interval):
                return interval.duration
            default:
                return nil
            }
        }.last         // Last resource loading event (might have several ones in a single session)
    }

    private var assetLoadingDuration: String {
        guard let assetLoadingInterval else { return "-" }
        return String(format: "%.6fs", assetLoadingInterval)
    }

    private var resourceLoadingDuration: String {
        guard let resourceLoadingInterval else { return "-" }
        return String(format: "%.6fs", resourceLoadingInterval)
    }

    private func cell(_ name: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
                .monospacedDigit()
                .lineLimit(1)
                .foregroundColor(.secondary)
        }
    }
}

struct MetricsView: View {
    private static let limit = 90

    @ObservedObject var metricsCollector: MetricsCollector

    var body: some View {
        Group {
            if !metrics.isEmpty {
                List {
                    informationSection()
                    startupTimesSection()
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

    private var metricEvents: [MetricEvent] {
        metricsCollector.metricEvents
    }

    private var currentMetrics: Metrics? {
        metrics.last
    }

    @ViewBuilder
    private func informationSection() -> some View {
        if let currentMetrics = metrics.last {
            Section {
                InformationSectionContent(metrics: currentMetrics)
            } header: {
                Text("Information")
            }
        }
    }

    @ViewBuilder
    private func startupTimesSection() -> some View {
        if let currentMetrics = metrics.last {
            Section {
                StartupTimesSectionContent(metrics: currentMetrics, metricEvents: metricEvents)
            } header: {
                Text("Startup times")
            }
        }
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
