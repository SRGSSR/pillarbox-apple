//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct MediaRequestChart: View {
    let metrics: [Metrics]

    var body: some View {
        Chart {
            ForEach(Array(metrics.enumerated()), id: \.offset) { metrics in
                BarMark(
                    x: .value("Index", metrics.offset),
                    y: .value("Media requests", metrics.element.increment.numberOfMediaRequests)
                )
                .foregroundStyle(.yellow)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
