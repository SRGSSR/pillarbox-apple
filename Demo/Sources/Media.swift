//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Media: Identifiable {
    static var liveMedia = Media(
        id: "live",
        title: "Couleur 3",
        description: "Couleur 3 livestream",
        source: .url(Stream.couleur3_livestream)
    )

    static var urnPlaylist: [Media] = [
        Media(
            id: "playlist:1",
            title: "Le Rencard 1",
            description: "Playlist item 1",
            source: .urn("urn:rts:video:13444390")
        ),
        Media(
            id: "playlist:2",
            title: "Le Rencard 2",
            description: "Playlist item 2",
            source: .urn("urn:rts:video:13444333")
        ),
        Media(
            id: "playlist:3",
            title: "Le Rencard 3",
            description: "Playlist item 3",
            source: .urn("urn:rts:video:13444466")
        ),
        Media(
            id: "playlist:4",
            title: "Le Rencard 4",
            description: "Playlist item 4",
            source: .urn("urn:rts:video:13444447")
        ),
        Media(
            id: "playlist:5",
            title: "Le Rencard 5",
            description: "Playlist item 5",
            source: .urn("urn:rts:video:13444352")
        ),
        Media(
            id: "playlist:6",
            title: "Le Rencard 6",
            description: "Playlist item 6",
            source: .urn("urn:rts:video:13444409")
        ),
        Media(
            id: "playlist:7",
            title: "Le Rencard 7",
            description: "Playlist item 7",
            source: .urn("urn:rts:video:13444371")
        ),
        Media(
            id: "playlist:8",
            title: "Le Rencard 8",
            description: "Playlist item 8",
            source: .urn("urn:rts:video:13444428")
        )
    ]

    static var urlPlaylist: [Media] = [
        Media(
            id: "playlist:1",
            title: "Le Rencard 1",
            description: "Playlist item 1",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444390/f1b478f7-2ae9-3166-94b9-c5d5fe9610df/master.m3u8")!)
        ),
        Media(
            id: "playlist:2",
            title: "Le Rencard 2",
            description: "Playlist item 2",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444333/feb1d08d-e62c-31ff-bac9-64c0a7081612/master.m3u8")!)
        ),
        Media(
            id: "playlist:3",
            title: "Le Rencard 3",
            description: "Playlist item 3",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444466/2787e520-412f-35fb-83d7-8dbb31b5c684/master.m3u8")!)
        ),
        Media(
            id: "playlist:4",
            title: "Le Rencard 4",
            description: "Playlist item 4",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444447/c1d17174-ad2f-31c2-a084-846a9247fd35/master.m3u8")!)
        ),
        Media(
            id: "playlist:5",
            title: "Le Rencard 5",
            description: "Playlist item 5",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444352/32145dc0-b5f8-3a14-ae11-5fc6e33aaaa4/master.m3u8")!)
        ),
        Media(
            id: "playlist:6",
            title: "Le Rencard 6",
            description: "Playlist item 6",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444409/23f808a4-b14a-3d3e-b2ed-fa1279f6cf01/master.m3u8")!)
        ),
        Media(
            id: "playlist:7",
            title: "Le Rencard 7",
            description: "Playlist item 7",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444371/3f26467f-cd97-35f4-916f-ba3927445920/master.m3u8")!)
        ),
        Media(
            id: "playlist:8",
            title: "Le Rencard 8",
            description: "Playlist item 8",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444428/857d97ef-0b8e-306e-bf79-3b13e8c901e4/master.m3u8")!)
        )
    ]

    let id: String
    let title: String
    let description: String
    let source: MediaSource
}
