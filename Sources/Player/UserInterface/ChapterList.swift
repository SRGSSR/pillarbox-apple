//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// TODO: Remove once tvOS 26 is not supported anymore.
@available(iOS, unavailable)
struct ChapterList: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    private var chapters: [Chapter] {
        player.metadata.chapters
    }

    private var currentChapter: Chapter? {
        chapters.first { $0.timeRange.containsTime(progressTracker.time) }
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 40) {
                ForEach(chapters, id: \.timeRange) { chapter in
                    ChapterCell(chapter: chapter, isHighlighted: chapter == currentChapter) {
                        player.seek(to: chapter)
                    }
                }
            }
        }
        .scrollClipDisabled_tvOS26()
        .bind(progressTracker, to: player)
    }
}

private extension View {
    func scrollClipDisabled_tvOS26() -> some View {
        if #available(tvOS 26, *) {
            return scrollClipDisabled()
        }
        else {
            return self
        }
    }
}
