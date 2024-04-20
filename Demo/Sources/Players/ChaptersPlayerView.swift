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
    let isHighlighted: Bool

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
        .saturation(isHighlighted ? 1 : 0)
        .scaleEffect17(isHighlighted ? 1.05 : 1)
        .animation(.defaultLinear, value: isHighlighted)
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
    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()
    @State private var layout: PlaybackView.Layout = .minimized
    @State private var chapters: [Chapter] = []
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))

    private var currentLayout: Binding<PlaybackView.Layout> {
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
            PlaybackView(player: model.player, layout: currentLayout)
                .supportsPictureInPicture()
                .enabledForInAppPictureInPicture(persisting: model)
            if layout != .maximized {
                chaptersView()
            }
        }
        .animation(.defaultLinear, values: layout, chapters)
        .background(.black)
        .bind(progressTracker, to: model.player)
        .onReceive(model.player.$metadata, assign: \.chapters, to: $chapters)
        .onAppear(perform: play)
        .tracked(name: "chapters-player")
    }

    private func play() {
        model.media = media
        model.play()
    }

    @ViewBuilder
    private func chaptersView() -> some View {
        if !chapters.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(chapters, id: \.timeRange) { chapter in
                        Button {
                            model.player.seek(to: chapter)
                        } label: {
                            ChapterView(chapter: chapter, isHighlighted: chapter == currentChapter)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled17()
        }
    }
}

extension ChaptersPlayerView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    ChaptersPlayerView(media: Media(from: URNTemplate.onDemandHorizontalVideo))
}
