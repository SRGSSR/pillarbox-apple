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
        VStack(alignment: .leading) {
            Text("Type: \(metrics.playbackType ?? "-")")
            if let playbackDuration {
                Text("Playback duration: \(playbackDuration)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
