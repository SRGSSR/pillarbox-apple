//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// TODO: Remove once tvOS 26 is not supported anymore.
@available(iOS, unavailable)
struct ChapterCell: View {
    let chapter: Chapter
    let action: () -> Void

    var body: some View {
        SwiftUI.Button(action: action) {
            LazyImage(source: chapter.imageSource) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
                    .frame(width: 320, height: 228, alignment: .top)
            }
        }
        .buttonStyle(.card)
    }
}
