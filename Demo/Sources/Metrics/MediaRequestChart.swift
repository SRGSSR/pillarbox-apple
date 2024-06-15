//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct MediaRequestChart: View {
    private static let maxX = 120

    let metrics: [Metrics]

    var body: some View {
        Chart(Array(metrics.suffix(Self.maxX).enumerated()), id: \.offset) { metrics in
            BarMark(
                x: .value("Index", metrics.offset),
                y: .value("Media requests", metrics.element.increment.numberOfMediaRequests)
            )
            .foregroundStyle(.yellow)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: 0...Self.maxX - 1)
        .padding()
    }
}
