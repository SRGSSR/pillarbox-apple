//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import SwiftUI

// TODO: Remove once tvOS 26 is not supported anymore.
struct ChapterList: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedTimeRange: CMTimeRange?

    private var chapters: [Chapter] {
        player.metadata.chapters
    }

    private var currentChapter: Chapter? {
        chapters.first { $0.timeRange.containsTime(progressTracker.time) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 40) {
                    ForEach(chapters, id: \.timeRange) { chapter in
                        ChapterCell(chapter: chapter, isHighlighted: chapter == currentChapter, isFocused: chapter.timeRange == focusedTimeRange) {
                            player.seek(to: chapter)
                            dismiss()
                        }
                        .focused($focusedTimeRange, equals: chapter.timeRange)
                        .id(chapter.timeRange)
                    }
                }
            }
            .scrollClipDisabled26()
            .bind(progressTracker, to: player)
            .onAppear {
                focusedTimeRange = currentChapter?.timeRange
                proxy.scrollTo(currentChapter?.timeRange)
            }
            .onChange(of: focusedTimeRange) { focusedTimeRange in
                // When a cell loses focus (e.g. leaving the list) focusedTimeRange becomes nil.
                // To avoid losing the last state we retain the current chapter time range.
                if focusedTimeRange == nil {
                    self.focusedTimeRange = currentChapter?.timeRange
                }
            }
        }
    }
}

private extension View {
    func scrollClipDisabled26() -> some View {
        if #available(iOS 26, tvOS 26, *) {
            return scrollClipDisabled()
        }
        else {
            return self
        }
    }
}
