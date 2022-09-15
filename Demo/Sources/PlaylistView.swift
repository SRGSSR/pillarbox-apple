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
    private let medias = [
        Media(
            id: "playlist:1",
            title: "Item 1",
            description: "Playlist item 1",
            source: .urn("urn:rts:video:13360549")
        ),
        Media(
            id: "playlist:2",
            title: "Item 2",
            description: "Playlist item 2",
            source: .urn("urn:rts:video:13270568")
        ),
        Media(
            id: "playlist:3",
            title: "Item 3",
            description: "Playlist item 3",
            source: .urn("urn:rts:video:13270535")
        ),
        Media(
            id: "playlist:4",
            title: "Item 4",
            description: "Playlist item 4",
            source: .urn("urn:rts:video:13228000")
        ),
        Media(
            id: "playlist:5",
            title: "Item 5",
            description: "Playlist item 5",
            source: .urn("urn:rts:video:13227903")
        ),
        Media(
            id: "playlist:6",
            title: "Item 6",
            description: "Playlist item 6",
            source: .urn("urn:rts:video:13161499")
        )
    ]

    var body: some View {
        ZStack {
            PlayerView(medias: medias)
        }
    }
}

// MARK: Preview

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView()
    }
}
