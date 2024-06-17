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

    private var playbackDuration: String? {
        Self.dateComponentsFormatter.string(from: metrics.total.playbackDuration)
    }

    var body: some View {
        cell("Type", value: metrics.playbackType ?? "-")
        if let playbackDuration {
            cell("Playback duration", value: playbackDuration)
        }
    }

    private func cell(_ name: String, value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }
    }
}
