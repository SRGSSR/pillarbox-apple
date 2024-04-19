//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

private struct ChapterView: View {
    let chapter: ChapterMetadata

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color(white: 1, opacity: 0.2)
                if let image = chapter.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .animation(.defaultLinear, value: chapter.image)
            .overlay {
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            if let title = chapter.title {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: 200, height: 200 * 9 / 16)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct ChaptersView: View {
    private let player = Player()

    @State private var layout: PlaybackView.Layout = .minimized
    @State private var chapters: [ChapterMetadata] = []
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    private var currentChapter: ChapterMetadata? {
        chapters.first { chapter in
            guard let time = progressTracker.time else { return false }
            return chapter.timeRange.containsTime(time)
        }
    }

    let media: Media

    var body: some View {
        VStack {
            PlaybackView(player: player, layout: $layout)
                .supportsPictureInPicture()
            if layout != .maximized {
                chaptersView()
            }
        }
        .animation(.defaultLinear, value: layout)
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
                        player.seek(at(chapter.timeRange.start + CMTime(value: 1, timescale: 10)))
                    }) {
                        ChapterView(chapter: chapter)
                            .saturation(currentChapter == chapter ? 1 : 0)
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

extension ChaptersView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    ChaptersView(media: Media(from: URNTemplate.onDemandHorizontalVideo))
}
