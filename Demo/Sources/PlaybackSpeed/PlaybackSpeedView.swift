//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct SettingsMenuView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        Menu(content: content) {
            Image(systemName: "ellipsis.circle")
                .tint(.white)
        }
    }
}

struct PlaybackSpeedView: View {
    var body: some View {
        SettingsMenuView {
            EmptyView()
        }
    }
}

struct PlaybackSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSpeedView()
            .background(.black)
    }
}
