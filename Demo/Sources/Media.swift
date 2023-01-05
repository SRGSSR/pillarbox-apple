//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreBusiness
import Foundation
import Player

// MARK: URL-based medias

enum MediaURL {
    static let onDemandVideoHLS = Media(
        title: "Switzerland says sorry! The fondue invasion",
        description: "VOD - HLS",
        type: .url(
            URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!
        )
    )
    static let shortOnDemandVideoHLS = Media(
        title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
        description: "VOD - HLS (short)",
        type: .url(
            URL(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!
        )
    )

    static let onDemandVideoMP4 = Media(
        title: "The dig",
        description: "VOD - MP4",
        type: .url(
            URL(string: "https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")!
        )
    )

    static let liveVideoHLS = Media(
        title: "Couleur 3 en vidéo",
        description: "Video livestream - HLS",
        type: .url(
            URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
        )
    )
    static let dvrVideoHLS = Media(
        title: "Couleur 3 en vidéo",
        description: "Video livestream with DVR - HLS",
        type: .url(
            URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")!
        )
    )
    static let liveTimestampVideoHLS = Media(
        title: "Video livestream with DVR and timestamps - HLS",
        description: "Tageschau",
        type: .url(
            URL(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!
        )
    )

    static let onDemandAudioMP3 = Media(
        title: "AOD - MP3",
        description: "On en parle",
        type: .url(
            URL(string: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")!
        )
    )
    static let liveAudioMP3 = Media(
        title: "Couleur 3",
        description: "Audio livestream - MP3",
        type: .url(
            URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
        )
    )

    static let dvrAudioHLS = Media(
        title: "Couleur 3",
        description: "Audio livestream - HLS",
        type: .url(
            URL(string: "https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")!
        )
    )

    // Apple streams from https://developer.apple.com/streaming/examples/
    static let appleBasic_4_3_HLS = Media(
        title: "Apple Basic 4:3",
        description: "4x3 aspect ratio, H.264 @ 30Hz",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!
        )
    )
    static let appleBasic_16_9_TS_HLS = Media(
        title: "Apple Basic 16:9",
        description: "16x9 aspect ratio, H.264 @ 30Hz",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        )
    )
    static let appleAdvanced_16_9_TS_HLS = Media(
        title: "Apple Advanced 16:9 (TS)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
        )
    )
    static let appleAdvanced_16_9_fMP4_HLS = Media(
        title: "Apple Advanced 16:9 (fMP4)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
        )
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Media(
        title: "Apple Advanced 16:9 (HEVC/H.264)",
        description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!
        )
    )

    static let onDemandVideoLocalHLS = Media(
        title: "Nyan cat",
        description: "Stream served locally",
        type: .url(
            URL(string: "http://localhost:8123/on_demand/master.m3u8")!
        )
    )

    static let unknown = Media(title: "Unknown URL", type: .url(URL(string: "http://localhost:8123/unavailable/master.m3u8")!))
}

// MARK: URN-based medias

enum MediaURN {
    static let onDemandHorizontalVideo = Media(
        title: "Horizontal video",
        type: .urn("urn:rts:video:6820736")
    )
    static let onDemandSquareVideo = Media(
        title: "Square video",
        type: .urn("urn:rts:video:8393241")
    )
    static let onDemandVerticalVideo = Media(
        title: "Vertical video",
        type: .urn("urn:rts:video:8412286")
    )
    static let tokenProtectedVideo = Media(
        title: "Ski alpin, Slalom Messieurs",
        description: "Token-protected video",
        type: .urn("urn:swisstxt:video:rts:1749666")
    )
    static let superfluousTokenProtectedVideo = Media(
        title: "Ul stralüsc",
        description: "Superfluously token-protected video",
        type: .urn("urn:rsi:video:15838291")
    )
    static let drmProtectedVideo = Media(
        title: "Top Models 8870",
        description: "DRM-protected video",
        type: .urn("urn:rts:video:13639837")
    )
    static let liveVideo = Media(
        title: "SRF 1 Live",
        description: "Live video",
        type: .urn("urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    )
    static let dvrVideo = Media(
        title: "RTS 1 en direct",
        description: "DVR video livestream",
        type: .urn("urn:rts:video:3608506")
    )
    static let dvrAudio = Media(
        title: "Couleur 3 en direct",
        description: "DVR audio livestream",
        type: .urn("urn:rts:audio:3262363")
    )
    static let onDemandAudio = Media(
        title: "Il lavoro di TerraProject per una fotografia documentaria",
        description: "On-demand audio stream",
        type: .urn("urn:rsi:audio:8833144")
    )
    static let expired = Media(
        title: "Film (expired)",
        description: "Content that is not available anymore",
        type: .urn("urn:rts:video:13382911")
    )
    static let unknown = Media(
        title: "Unknown URN",
        description: "Content that does not exist",
        type: .urn("urn:srf:video:unknown")
    )
}

// MARK: Unbuffered URL-based medias

enum UnbufferedMediaURL {
    static let liveVideo = Media(
        title: "Couleur 3 en direct",
        description: "Live video",
        type: .unbufferedUrl(
            URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
        )
    )
    static let onDemandAudio = Media(
        title: "Forum",
        description: "On-demand audio stream",
        type: .unbufferedUrl(
            URL(string: "https://rts-aod-dd.akamaized.net/ww/13432709/2be967ad-e8a5-33c3-8560-83702436fb2e.mp3")!
        )
    )
    static let liveAudio = Media(
        title: "Couleur 3 en direct",
        description: "Audio livestream",
        type: .unbufferedUrl(
            URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
        )
    )
}

// MARK: Playlists

enum URLPlaylist {
    static let videos: [Media] = [
        Media(
            title: "Le R. - Légumes trop chers",
            description: "Playlist item 1",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444390/f1b478f7-2ae9-3166-94b9-c5d5fe9610df/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Production de légumes bio",
            description: "Playlist item 2",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444333/feb1d08d-e62c-31ff-bac9-64c0a7081612/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Endométriose",
            description: "Playlist item 3",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444466/2787e520-412f-35fb-83d7-8dbb31b5c684/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Prix Nobel de littérature 2022",
            description: "Playlist item 4",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444447/c1d17174-ad2f-31c2-a084-846a9247fd35/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Femme, vie, liberté",
            description: "Playlist item 5",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444352/32145dc0-b5f8-3a14-ae11-5fc6e33aaaa4/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Attaque en Thaïlande",
            description: "Playlist item 6",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444409/23f808a4-b14a-3d3e-b2ed-fa1279f6cf01/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Douches et vestiaires non genrés",
            description: "Playlist item 7",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444371/3f26467f-cd97-35f4-916f-ba3927445920/master.m3u8")!
            )
        ),
        Media(
            title: "Le R. - Prends soin de toi, des autres et à demain",
            description: "Playlist item 8",
            type: .url(
                URL(string: "https://rts-vod-amd.akamaized.net/ww/13444428/857d97ef-0b8e-306e-bf79-3b13e8c901e4/master.m3u8")!
            )
        )
    ]
}

enum URNPlaylist {
    static let videos: [Media] = [
        Media(
            title: "Le R. - Légumes trop chers",
            description: "Playlist item 1",
            type: .urn("urn:rts:video:13444390")
        ),
        Media(
            title: "Le R. - Production de légumes bio",
            description: "Playlist item 2",
            type: .urn("urn:rts:video:13444333")
        ),
        Media(
            title: "Le R. - Endométriose",
            description: "Playlist item 3",
            type: .urn("urn:rts:video:13444466")
        ),
        Media(
            title: "Le R. - Prix Nobel de littérature 2022",
            description: "Playlist item 4",
            type: .urn("urn:rts:video:13444447")
        ),
        Media(
            title: "Le R. - Femme, vie, liberté",
            description: "Playlist item 5",
            type: .urn("urn:rts:video:13444352")
        ),
        Media(
            title: "Le R. - Attaque en Thailande",
            description: "Playlist item 6",
            type: .urn("urn:rts:video:13444409")
        ),
        Media(
            title: "Le R. - Douches et vestinaires non genrés",
            description: "Playlist item 7",
            type: .urn("urn:rts:video:13444371")
        ),
        Media(
            title: "Le R. - Prend soin de toi des autres et à demain",
            description: "Playlist item 8",
            type: .urn("urn:rts:video:13444428")
        )
    ]

    static let longVideos: [Media] = [
        Media(
            title: "J'ai pas l'air malade mais… (#1)",
            description: "Playlist item 1",
            type: .urn("urn:rts:video:13588169")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#2)",
            description: "Playlist item 2",
            type: .urn("urn:rts:video:13555428")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#3)",
            description: "Playlist item 3",
            type: .urn("urn:rts:video:13529000")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#4)",
            description: "Playlist item 4",
            type: .urn("urn:rts:video:13471319")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#5)",
            description: "Playlist item 5",
            type: .urn("urn:rts:video:13446843")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#6)",
            description: "Playlist item 6",
            type: .urn("urn:rts:video:13403392")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#7)",
            description: "Playlist item 7",
            type: .urn("urn:rts:video:13387184")
        ),
        Media(
            title: "J'ai pas l'air malade mais… (#8)",
            description: "Playlist item 8",
            type: .urn("urn:rts:video:13296253")
        )
    ]

    static let videosWithOneError: [Media] = [
        MediaURL.shortOnDemandVideoHLS,
        MediaURN.unknown,
        MediaURL.onDemandVideoHLS
    ]

    static let videosWithErrors: [Media] = [
        MediaURL.unknown,
        MediaURN.unknown,
    ]

    static let tokenProtectedVideos: [Media] = [
        Media(
            title: "Ski alpin, Slalom Messieurs",
            description: "Token-protected video 1",
            type: .urn("urn:swisstxt:video:rts:1749666")
        ),
        Media(
            title: "Ski alpin, Slalom Dames",
            description: "Token-protected video 2",
            type: .urn("urn:swisstxt:video:rts:1749741")
        ),
    ]

    static let drmProtectedVideos: [Media] = [
        Media(
            title: "Top Models 8870",
            description: "DRM-protected video 1",
            type: .urn("urn:rts:video:13639837")
        ),
        Media(
            title: "Top Models 8869",
            description: "DRM-protected video 2",
            type: .urn("urn:rts:video:13639830")
        )
    ]

    static let audios: [Media] = [
        Media(title: "Le Journal horaire 1", type: .urn("urn:rts:audio:13605286")),
        Media(title: "Forum", type: .urn("urn:rts:audio:13598743")),
        Media(title: "Vertigo", type: .urn("urn:rts:audio:13579611")),
        Media(title: "Le Journal horaire 2", type: .urn("urn:rts:audio:13605216"))
    ]
}

// MARK: Types

struct Media: Hashable {
    enum `Type`: Hashable {
        case url(URL)
        case unbufferedUrl(URL)
        case urn(String)
    }

    let title: String
    let description: String?
    let type: `Type`

    init(title: String, description: String? = nil, type: Type) {
        self.title = title
        self.description = description
        self.type = type
    }

    var playerItem: PlayerItem {
        switch type {
        case let .url(url):
            return PlayerItem(url: url)
        case let .unbufferedUrl(url):
            return PlayerItem(url: url) { item in
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
        case let .urn(urn):
            return PlayerItem(urn: urn)
        }
    }
}
