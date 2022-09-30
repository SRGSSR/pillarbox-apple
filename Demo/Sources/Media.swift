//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Media: Identifiable {
    static var urnPlaylist: [Media] = [
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

    static var urlPlaylist: [Media] = [
        Media(
            id: "playlist:1",
            title: "Item 1",
            description: "Playlist item 1",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13360549/8767046e-2bb2-367c-9489-f0db42fa895d/master.m3u8")!)
        ),
        Media(
            id: "playlist:2",
            title: "Item 2",
            description: "Playlist item 2",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13270568/a5aa3481-618b-390b-aeda-4c24324fff0a/master.m3u8")!)
        ),
        Media(
            id: "playlist:3",
            title: "Item 3",
            description: "Playlist item 3",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13270535/d47afd3d-a0ba-3b59-a3ed-d806097b8a7e/master.m3u8")!)
        ),
        Media(
            id: "playlist:4",
            title: "Item 4",
            description: "Playlist item 4",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13228000/afda78a2-b04b-346c-b01c-00e6a617b993/master.m3u8")!)
        ),
        Media(
            id: "playlist:5",
            title: "Item 5",
            description: "Playlist item 5",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13227903/ee11ce1e-637c-3504-bf80-845143534b47/master.m3u8")!)
        ),
        Media(
            id: "playlist:6",
            title: "Item 6",
            description: "Playlist item 6",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13161499/6a317edc-283f-3118-a873-f45f4d54f13d/master.m3u8")!)
        )
    ]

    let id: String
    let title: String
    let description: String
    let source: MediaSource
}
