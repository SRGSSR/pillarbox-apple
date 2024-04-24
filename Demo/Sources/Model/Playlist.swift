//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum Playlist {
    static let lemanBleu: [Template] = [
        URLTemplate.lemanBleuLive,
        URLTemplate.lemanBleu1,
        URLTemplate.lemanBleu2,
        URLTemplate.lemanBleu3
    ]

    static let videoUrls: [Template] = [
        Template(
            title: "Le R. - Légumes trop chers",
            subtitle: "Playlist item 1",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444390/f1b478f7-2ae9-3166-94b9-c5d5fe9610df/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Production de légumes bio",
            subtitle: "Playlist item 2",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444333/feb1d08d-e62c-31ff-bac9-64c0a7081612/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Endométriose",
            subtitle: "Playlist item 3",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444466/2787e520-412f-35fb-83d7-8dbb31b5c684/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Prix Nobel de littérature 2022",
            subtitle: "Playlist item 4",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444447/c1d17174-ad2f-31c2-a084-846a9247fd35/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Femme, vie, liberté",
            subtitle: "Playlist item 5",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444352/32145dc0-b5f8-3a14-ae11-5fc6e33aaaa4/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Attaque en Thaïlande",
            subtitle: "Playlist item 6",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444409/23f808a4-b14a-3d3e-b2ed-fa1279f6cf01/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Douches et vestiaires non genrés",
            subtitle: "Playlist item 7",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444371/3f26467f-cd97-35f4-916f-ba3927445920/master.m3u8"
            )
        ),
        Template(
            title: "Le R. - Prends soin de toi, des autres et à demain",
            subtitle: "Playlist item 8",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13444428/857d97ef-0b8e-306e-bf79-3b13e8c901e4/master.m3u8"
            )
        )
    ]

    static let videoUrns: [Template] = [
        Template(
            title: "Le R. - Légumes trop chers",
            subtitle: "Playlist item 1",
            type: .urn("urn:rts:video:13444390")
        ),
        Template(
            title: "Le R. - Production de légumes bio",
            subtitle: "Playlist item 2",
            type: .urn("urn:rts:video:13444333")
        ),
        Template(
            title: "Le R. - Endométriose",
            subtitle: "Playlist item 3",
            type: .urn("urn:rts:video:13444466")
        ),
        Template(
            title: "Le R. - Prix Nobel de littérature 2022",
            subtitle: "Playlist item 4",
            type: .urn("urn:rts:video:13444447")
        ),
        Template(
            title: "Le R. - Femme, vie, liberté",
            subtitle: "Playlist item 5",
            type: .urn("urn:rts:video:13444352")
        ),
        Template(
            title: "Le R. - Attaque en Thailande",
            subtitle: "Playlist item 6",
            type: .urn("urn:rts:video:13444409")
        ),
        Template(
            title: "Le R. - Douches et vestinaires non genrés",
            subtitle: "Playlist item 7",
            type: .urn("urn:rts:video:13444371")
        ),
        Template(
            title: "Le R. - Prend soin de toi des autres et à demain",
            subtitle: "Playlist item 8",
            type: .urn("urn:rts:video:13444428")
        )
    ]

    static let longVideoUrns: [Template] = [
        Template(
            title: "J'ai pas l'air malade mais… (#1)",
            subtitle: "Playlist item 1",
            type: .urn("urn:rts:video:13588169")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#2)",
            subtitle: "Playlist item 2",
            type: .urn("urn:rts:video:13555428")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#3)",
            subtitle: "Playlist item 3",
            type: .urn("urn:rts:video:13529000")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#4)",
            subtitle: "Playlist item 4",
            type: .urn("urn:rts:video:13471319")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#5)",
            subtitle: "Playlist item 5",
            type: .urn("urn:rts:video:13446843")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#6)",
            subtitle: "Playlist item 6",
            type: .urn("urn:rts:video:13403392")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#7)",
            subtitle: "Playlist item 7",
            type: .urn("urn:rts:video:13387184")
        ),
        Template(
            title: "J'ai pas l'air malade mais… (#8)",
            subtitle: "Playlist item 8",
            type: .urn("urn:rts:video:13296253")
        )
    ]

    static let videosWithMediaSelections: [Template] = [
        URLTemplate.appleTvMorningShowSeason1Trailer,
        URLTemplate.appleTvMorningShowSeason2Trailer
    ]

    static let audios: [Template] = [
        Template(title: "Le Journal horaire 1", type: .urn("urn:rts:audio:13605286")),
        Template(title: "Forum", type: .urn("urn:rts:audio:13598743")),
        Template(title: "Vertigo", type: .urn("urn:rts:audio:13579611")),
        Template(title: "Le Journal horaire 2", type: .urn("urn:rts:audio:13605216"))
    ]

    static let videosWithOneFailingUrl: [Template] = [
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.unknown,
        URLTemplate.onDemandVideoHLS
    ]

    static let videosWithOneFailingMp3Url: [Template] = [
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.unavailableMp3,
        URLTemplate.onDemandVideoHLS
    ]

    static let videosWithOneFailingUrn: [Template] = [
        URNTemplate.onDemandVideo,
        URNTemplate.unknown,
        URNTemplate.onDemandSquareVideo
    ]

    static let videosWithOnlyFailingUrns: [Template] = [
        URNTemplate.unknown,
        URNTemplate.expired
    ]

    static let videosWithOnlyFailingUrls: [Template] = [
        URLTemplate.unknown,
        URLTemplate.unauthorized
    ]

    static let videosWithFailingUrlsAndUrns: [Template] = [
        URNTemplate.unknown,
        URLTemplate.unknown,
        URNTemplate.expired,
        URLTemplate.unauthorized,
        URLTemplate.unavailableMp3
    ]
}
