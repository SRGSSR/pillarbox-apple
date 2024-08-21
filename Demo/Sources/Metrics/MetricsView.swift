//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxMonitoring
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
        cell("Buffering", value: startupTime)
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

    private var startupTime: String {
        guard let startupTime = metrics.startupTime else { return "-" }
        return String(format: "%.6fs", startupTime)
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
    let metricEvents: [MetricEvent]

    var body: some View {
        cell("Metadata", value: metadataDuration)
        cell("Asset", value: assetDuration)
        cell("Total", value: totalDuration)
    }

    private var metadataInterval: TimeInterval? {
        metricEvents.compactMap { event in
            switch event.kind {
            case let .metadata(interval):
                return interval.duration
            default:
                return nil
            }
        }.last
    }

    private var assetInterval: TimeInterval? {
        metricEvents.compactMap { event in
            switch event.kind {
            case let .asset(interval):
                return interval.duration
            default:
                return nil
            }
        }.last
    }

    private var totalDuration: String {
        guard let assetInterval, let metadataInterval else { return "-" }
        let totalInterval = assetInterval + metadataInterval
        return String(format: "%.6fs", totalInterval)
    }

    private var metadataDuration: String {
        guard let metadataInterval else { return "-" }
        return String(format: "%.6fs", metadataInterval)
    }

    private var assetDuration: String {
        guard let assetInterval else { return "-" }
        return String(format: "%.6fs", assetInterval)
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
    @ObservedObject var metricsCollector: MetricsCollector

    var body: some View {
        Group {
            if !metricsCollector.isEmpty {
                list()
            }
            else {
                MessageView(message: "No metrics", icon: .system("chart.bar"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .transaction { $0.animation = nil }
        .navigationTitle("Metrics")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }

    private var metrics: [Metrics] {
        metricsCollector.metrics
    }

    private func list() -> some View {
        List {
            startupTimesSection()
            trackingSection()
            if !metricsCollector.metrics.isEmpty {
                informationSection()
                indicatedBitrateChartSection()
                observedBitrateChartSection()
                dataVolumeChartSection()
                mediaRequestsChartSection()
                stallsChartSection()
                frameDropsChartSection()
            }
            eventLogSection()
        }
    }

    @ViewBuilder
    private func startupTimesSection() -> some View {
        Section {
            StartupTimesSectionContent(metricEvents: metricsCollector.metricEvents)
        } header: {
            Text("Startup times")
        }
    }

    @ViewBuilder
    private func trackingSection() -> some View {
        let sessionIdentifiers = sessionIdentifiers()
        if !sessionIdentifiers.isEmpty {
            Section {
                ForEach(sessionIdentifiers, id: \.self) { identifier in
                    Text(identifier)
#if os(iOS)
                        .textSelection(.enabled)
#endif
                }
            } header: {
                Text("Tracking sessions")
            }
        }
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
    private func indicatedBitrateChartSection() -> some View {
        Section {
            IndicatedBitrateChart(metrics: metrics, limit: metricsCollector.limit)
        } header: {
            Text("Indicated bitrate")
        }
    }

    @ViewBuilder
    private func observedBitrateChartSection() -> some View {
        Section {
            ObservedBitrateChart(metrics: metrics, limit: metricsCollector.limit)
        } header: {
            Text("Observed bitrate")
        }
    }

    @ViewBuilder
    private func dataVolumeChartSection() -> some View {
        Section {
            DataVolumeChart(metrics: metrics, limit: metricsCollector.limit)
        } header: {
            Text("Data volume")
        }
    }

    @ViewBuilder
    private func mediaRequestsChartSection() -> some View {
        Section {
            MediaRequestChart(metrics: metrics, limit: metricsCollector.limit)
        } header: {
            Text("Media requests")
        }
    }

    @ViewBuilder
    private func stallsChartSection() -> some View {
        Section {
            StallsChart(metrics: metrics, limit: metricsCollector.limit)
        } header: {
            Text("Stalls")
        }
    }

    @ViewBuilder
    private func frameDropsChartSection() -> some View {
        Section {
            FrameDropsChart(metrics: metrics, limit: metricsCollector.limit)
        } header: {
            Text("Frame drops")
        }
    }

    private func eventLogSection() -> some View {
        Section {
            ForEach(metricsCollector.metricEvents, id: \.self) { event in
                MetricEventCell(event: event)
            }
        } header: {
            Text("Event log")
        }
    }

    private func sessionIdentifiers() -> [String] {
        guard let player = metricsCollector.player else { return [] }
        return player.currentSessionIdentifiers(trackedBy: MetricsTracker.self)
    }
}

struct MetricsView_Previews: PreviewProvider {
    private struct MetricsPreview: View {
        @State private var player = Player(item: URLMedia.appleAdvanced_16_9_TS_HLS.item())
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
