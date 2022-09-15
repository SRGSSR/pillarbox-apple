//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI
import UserInterface

// MARK: View

struct PlaylistView: View {
    let media = Media(
        id: "1",
        title: "First media",
        description: "1",
        source: .urn("urn:rts:video:6820736")
    )

    var body: some View {
        ZStack {
            PlayerView(media: media)
        }
    }
}

// MARK: Preview

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
