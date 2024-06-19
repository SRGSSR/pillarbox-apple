//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct MetricsInfoView: View {
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
        cell("Startup time", value: startupTime)
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

    private func cell(_ name: String, value: String) -> some View {
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
