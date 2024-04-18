//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct ChapterView: View {
    let chapter: ChapterMetadata

    var body: some View {
        VStack {
            if let image = chapter.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            if let title = chapter.title {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
        }
        .frame(width: 200)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct ChaptersView: View {
    private let player = Player()
    @State private var chapters: [ChapterMetadata] = []
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    private var currentChapter: ChapterMetadata? {
        chapters.first { chapter in
            chapter.timeRange.containsTime(player.time)
        }
    }

    let media: Media

    var body: some View {
        VStack {
            PlaybackView(player: player)
            chaptersView()
        }
        .background(.black)
        .bind(progressTracker, to: player)
        .onReceive(player.$metadata, assign: \.chapters, to: $chapters)
        .onAppear(perform: play)
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }

    private func chaptersView() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(chapters, id: \.timeRange) { chapter in
                    Button(action: {
                        player.seek(to: chapter.timeRange.start)
                    }) {
                        ChapterView(chapter: chapter)
                            .saturation(currentChapter == chapter ? 1 : 0)
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        ._debugBodyCounter(color: .green)
    }
}

extension ChaptersView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    ChaptersView(media: Media(from: URNTemplate.onDemandHorizontalVideo))
}
