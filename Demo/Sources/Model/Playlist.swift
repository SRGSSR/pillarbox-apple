//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum Playlist {
    static let videoUrls = [
        Media(
            title: "Le R. - Légumes trop chers",
            subtitle: "Playlist item 1",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444390/f1b478f7-2ae9-3166-94b9-c5d5fe9610df/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Production de légumes bio",
            subtitle: "Playlist item 2",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444333/feb1d08d-e62c-31ff-bac9-64c0a7081612/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Endométriose",
            subtitle: "Playlist item 3",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444466/2787e520-412f-35fb-83d7-8dbb31b5c684/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Prix Nobel de littérature 2022",
            subtitle: "Playlist item 4",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444447/c1d17174-ad2f-31c2-a084-846a9247fd35/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Femme, vie, liberté",
            subtitle: "Playlist item 5",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444352/32145dc0-b5f8-3a14-ae11-5fc6e33aaaa4/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Attaque en Thaïlande",
            subtitle: "Playlist item 6",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444409/23f808a4-b14a-3d3e-b2ed-fa1279f6cf01/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Douches et vestiaires non genrés",
            subtitle: "Playlist item 7",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444371/3f26467f-cd97-35f4-916f-ba3927445920/master.m3u8"
            )
        ),
        Media(
            title: "Le R. - Prends soin de toi, des autres et à demain",
            subtitle: "Playlist item 8",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444428/857d97ef-0b8e-306e-bf79-3b13e8c901e4/master.m3u8"
            )
        )
    ]

    static let videoUrns = [
        Media(
            title: "Le R. - Légumes trop chers",
            subtitle: "Playlist item 1",
            type: .urn("urn:rts:video:13444390")
        ),
        Media(
            title: "Le R. - Production de légumes bio",
            subtitle: "Playlist item 2",
            type: .urn("urn:rts:video:13444333")
        ),
        Media(
            title: "Le R. - Endométriose",
            subtitle: "Playlist item 3",
            type: .urn("urn:rts:video:13444466")
        ),
        Media(
            title: "Le R. - Prix Nobel de littérature 2022",
            subtitle: "Playlist item 4",
            type: .urn("urn:rts:video:13444447")
        ),
        Media(
            title: "Le R. - Femme, vie, liberté",
            subtitle: "Playlist item 5",
            type: .urn("urn:rts:video:13444352")
        ),
        Media(
            title: "Le R. - Attaque en Thailande",
            subtitle: "Playlist item 6",
            type: .urn("urn:rts:video:13444409")
        ),
        Media(
            title: "Le R. - Douches et vestinaires non genrés",
            subtitle: "Playlist item 7",
            type: .urn("urn:rts:video:13444371")
        ),
        Media(
            title: "Le R. - Prend soin de toi des autres et à demain",
            subtitle: "Playlist item 8",
            type: .urn("urn:rts:video:13444428")
        )
    ]

    static let longVideoUrns = [
        Media(
            title: "J'ai pas l'air malade mais… (#1)",
            subtitle: "Playlist item 1",
            type: .urn("urn:rts:video:13588169")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#2)",
            subtitle: "Playlist item 2",
            type: .urn("urn:rts:video:13555428")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#3)",
            subtitle: "Playlist item 3",
            type: .urn("urn:rts:video:13529000")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#4)",
            subtitle: "Playlist item 4",
            type: .urn("urn:rts:video:13471319")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#5)",
            subtitle: "Playlist item 5",
            type: .urn("urn:rts:video:13446843")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#6)",
            subtitle: "Playlist item 6",
            type: .urn("urn:rts:video:13403392")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#7)",
            subtitle: "Playlist item 7",
            type: .urn("urn:rts:video:13387184")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#8)",
            subtitle: "Playlist item 8",
            type: .urn("urn:rts:video:13296253")
        )
    ]

    static let videosWithMediaSelections = [
        URLMedia.appleTvMorningShowSeason1Trailer,
        URLMedia.appleTvMorningShowSeason2Trailer
    ]

    static let audios = [
        Media(title: "Le Journal horaire 1", type: .urn("urn:rts:audio:13605286")),
        Media(title: "Forum", type: .urn("urn:rts:audio:13598743")),
        Media(title: "Vertigo", type: .urn("urn:rts:audio:13579611")),
        Media(title: "Le Journal horaire 2", type: .urn("urn:rts:audio:13605216"))
    ]

    static let videosWithOneFailingUrl = [
        URLMedia.shortOnDemandVideoHLS,
        URLMedia.unknown,
        URLMedia.onDemandVideoHLS
    ]

    static let videosWithOneFailingMp3Url = [
        URLMedia.shortOnDemandVideoHLS,
        URLMedia.unavailableMp3,
        URLMedia.onDemandVideoHLS
    ]

    static let videosWithOneFailingUrn = [
        URNMedia.onDemandVideo,
        URNMedia.unknown,
        URNMedia.onDemandSquareVideo
    ]

    static let videosWithOnlyFailingUrns = [
        URNMedia.unknown,
        URNMedia.expired
    ]

    static let videosWithOnlyFailingUrls = [
        URLMedia.unknown,
        URLMedia.unauthorized
    ]

    static let videosWithFailingUrlsAndUrns = [
        URNMedia.unknown,
        URLMedia.unknown,
        URNMedia.expired,
        URLMedia.unauthorized,
        URLMedia.unavailableMp3
    ]
}
