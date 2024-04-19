//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer
import SwiftUI

private struct ChapterView: View {
    private static let width: CGFloat = 200

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    let chapter: Chapter

    private var formattedDuration: String? {
        Self.durationFormatter.string(from: Double(chapter.timeRange.duration.seconds))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            imageView()
            titleView()
        }
        .frame(width: Self.width, height: Self.width * 9 / 16)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    @ViewBuilder
    private func imageView() -> some View {
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
        .overlay(alignment: .topTrailing) {
            durationLabel()
        }
    }

    @ViewBuilder
    private func titleView() -> some View {
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

    @ViewBuilder
    private func durationLabel() -> some View {
        if let formattedDuration {
            Text(formattedDuration)
                .font(.caption2)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(white: 0, opacity: 0.8))
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(8)
        }
    }
}

struct ChaptersPlayerView: View {
    private let player = Player()
    @State private var layout: PlaybackView.Layout = .minimized
    @State private var chapters: [Chapter] = []
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    private var effectiveLayout: Binding<PlaybackView.Layout> {
        !chapters.isEmpty ? $layout : .constant(.inline)
    }

    private var currentChapter: Chapter? {
        chapters.first { chapter in
            guard let time = progressTracker.time else { return false }
            return chapter.timeRange.containsTime(time)
        }
    }

    let media: Media

    var body: some View {
        VStack {
            PlaybackView(player: player, layout: effectiveLayout)
                .supportsPictureInPicture()
            if layout != .maximized {
                chaptersView()
            }
        }
        .animation(.defaultLinear, values: layout, chapters)
        .background(.black)
        .bind(progressTracker, to: player)
        .onReceive(player.$metadata, assign: \.chapters, to: $chapters)
        .onAppear(perform: play)
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }

    @ViewBuilder
    private func chaptersView() -> some View {
        if !chapters.isEmpty {
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
}

extension ChaptersPlayerView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    ChaptersPlayerView(media: Media(from: URNTemplate.onDemandHorizontalVideo))
}
