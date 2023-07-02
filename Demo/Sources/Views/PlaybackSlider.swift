//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaybackSlider: View {
    let minimumValueText: String = ""
    let maximumValueText: String = ""

    var body: some View {
        HStack {
            text(minimumValueText)
            Rectangle()
            text(maximumValueText)
        }
    }

    @ViewBuilder
    private func text(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .fixedSize()
    }
}

struct PlaybackSlider_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSlider()
            .padding(.horizontal, 5)
    }
}
