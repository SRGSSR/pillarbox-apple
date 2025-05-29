//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

struct MetricEventCell: View {
    private static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private static let durationFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    let event: MetricEvent

    private var time: String {
        if let duration = Self.duration(from: event.time) {
            return "[\(duration)] \(formattedDate)"
        }
        else {
            return formattedDate
        }
    }

    private var description: String {
        event.kind.description
    }

    private var formattedDate: String {
        Self.dateFormatter.string(from: event.date)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(time)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(description)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .accessibilityElement()
        .accessibilityLabel(description)
    }

    private static func duration(from time: CMTime) -> String? {
        guard time.isValid else { return nil }
        return durationFormatter.string(from: time.seconds)
    }
}
