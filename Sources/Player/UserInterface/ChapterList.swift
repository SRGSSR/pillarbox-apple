//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// TODO: Remove once tvOS 26 is not supported anymore.
struct ChapterList: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedChapterId: Chapter.ID?

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
                    ForEach(chapters) { chapter in
                        ChapterCell(chapter: chapter, isHighlighted: chapter == currentChapter, isFocused: chapter.id == focusedChapterId) {
                            player.seek(to: chapter)
                            dismiss()
                        }
                        .focused($focusedChapterId, equals: chapter.id)
                        .id(chapter.id)
                    }
                }
            }
            .scrollClipDisabled26()
            .bind(progressTracker, to: player)
            .onAppear {
                focusedChapterId = currentChapter?.id
                proxy.scrollTo(currentChapter?.id)
            }
            .onChange(of: focusedChapterId) { focusedChapterId in
                // When a cell loses focus (e.g. leaving the list) focusedChapterId becomes nil.
                // To avoid losing the last state we retain the current chapter identity.
                if focusedChapterId == nil {
                    self.focusedChapterId = currentChapter?.id
                }
            }
        }
    }
}

private extension View {
    func scrollClipDisabled26() -> some View {
        if #available(anyAppleOS 26, *) {
            return scrollClipDisabled()
        }
        else {
            return self
        }
    }
}
