//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SkipButton: View {
    let player: Player
    @ObservedObject var progressTracker: ProgressTracker

    private var skippableTimeRange: TimeRange? {
        player.skippableTimeRange(at: progressTracker.playbackPosition)
    }

    var body: some View {
        Button(action: skip) {
            Text("Skip")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(white: 0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(Color(white: 0.3))
                }
        }
        .opacity(skippableTimeRange != nil ? 1 : 0)
        .animation(.easeInOut, value: skippableTimeRange)
    }

    private func skip() {
        guard let skippableTimeRange else { return }
        switch skippableTimeRange.end { // FIXME: Seek to Mark?
        case let .time(time):
            player.seek(to: time)
        case let .date(date):
            player.seek(to: date)
        }
    }
}
