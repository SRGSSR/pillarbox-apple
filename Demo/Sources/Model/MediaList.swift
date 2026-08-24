//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum MediaList {
    static let videoUrls = [
        Media(
            title: "Mario vs Sonic",
            subtitle: "Tataki 1",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13950405/fa79f98c-9e72-32c4-812e-aa5ba94cd568/master.m3u8"
            )
        ),
        Media(
            title: "Pourquoi Beyoncé fait de la country",
            subtitle: "Tataki 2",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/14815579/fec583e8-5d42-3994-8f76-70c550a2ae8e/master.m3u8"
            )
        ),
        Media(
            title: "L'île North Sentinel",
            subtitle: "Tataki 3",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13795051/86f7f1f6-9857-3aa7-8de6-c23247a307f0/master.m3u8"
            )
        ),
        Media(
            title: "Mourir pour ressembler à une idole",
            subtitle: "Tataki 4",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/14020134/f47b0e62-5fb9-3ce9-b587-3b3a0113ba11/master.m3u8"
            )
        ),
        Media(
            title: "Pourquoi les gens mangent des insectes ?",
            subtitle: "Tataki 5",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/12631996/15de3331-6b0c-3890-a59d-5b09453c58f8/master.m3u8"
            )
        ),
        Media(
            title: "Le concert de Beyoncé à Dubai",
            subtitle: "Tataki 6",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/13752646/c4c1d901-0690-3cb5-a1d2-626449f0f096/master.m3u8"
            )
        ),
        Media(
            title: "La banane la plus chère du monde",
            subtitle: "Tataki 7",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/15429800/9ecf5358-8e65-3cd4-8071-086089b99bb6/master.m3u8"
            )
        ),
        Media(
            title: "La trend Chill Guy",
            subtitle: "Tataki 8",
            type: .url(
                "https://rts-vod-amd.akamaized.net/ww/15429899/9913ec6b-6386-3805-9c3a-12f32048e046/master.m3u8"
            )
        )
    ]

    static let videoUrns = [
        Media(
            title: "Mario vs Sonic",
            subtitle: "Tataki 1",
            type: .urn("urn:rts:video:13950405")
        ),
        Media(
            title: "Pourquoi Beyoncé fait de la country",
            subtitle: "Tataki 2",
            type: .urn("urn:rts:video:14815579")
        ),
        Media(
            title: "L'île North Sentinel",
            subtitle: "Tataki 3",
            type: .urn("urn:rts:video:13795051")
        ),
        Media(
            title: "Mourir pour ressembler à une idole",
            subtitle: "Tataki 4",
            type: .urn("urn:rts:video:14020134")
        ),
        Media(
            title: "Pourquoi les gens mangent des insectes ?",
            subtitle: "Tataki 5",
            type: .urn("urn:rts:video:12631996")
        ),
        Media(
            title: "Le concert de Beyoncé à Dubai",
            subtitle: "Tataki 6",
            type: .urn("urn:rts:video:13752646")
        ),
        Media(
            title: "La banane la plus chère du monde",
            subtitle: "Tataki 7",
            type: .urn("urn:rts:video:15429800")
        ),
        Media(
            title: "La trend Chill Guy",
            subtitle: "Tataki 8",
            type: .urn("urn:rts:video:15429899")
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
        URNMedia.unknown
    ]

    static let videosWithOnlyFailingUrls = [
        URLMedia.unknown,
        URLMedia.unauthorized
    ]

    static let videosWithFailingUrlsAndUrns = [
        URNMedia.unknown,
        URLMedia.unknown,
        URLMedia.unauthorized,
        URLMedia.unavailableMp3
    ]
}
