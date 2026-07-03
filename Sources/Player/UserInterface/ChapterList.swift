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

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 40) {
                ForEach(player.metadata.chapters, id: \.timeRange) { chapter in
                    ChapterCell(chapter: chapter) {
                        player.seek(to: chapter)
                    }
                }
            }
        }
        .scrollClipDisabled_tvOS26()
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
