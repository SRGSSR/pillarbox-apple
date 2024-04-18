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

    let media: Media

    var body: some View {
        VStack {
            PlaybackView(player: player)
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(chapters, id: \.timeRange) { chapter in
                        ChapterView(chapter: chapter)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
        .background(.black)
        .onReceive(player.$metadata, assign: \.chapters, to: $chapters)
        .onAppear(perform: play)
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

extension ChaptersView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    ChaptersView(media: Media(from: URNTemplate.onDemandHorizontalVideo))
}
