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
    static let onDemandVideoHLS = Media.url(
        URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!
    )
    static let shortOnDemandVideoHLS = Media.url(
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!
    )

    static let onDemandVideoMP4 = Media.url(
        URL(string: "https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")!
    )

    static let liveVideoHLS = Media.url(
        URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
    )
    static let dvrVideoHLS = Media.url(
        URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")!
    )
    static let liveTimestampVideoHLS = Media.url(
        URL(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!
    )

    static let onDemandAudioMP3 = Media.url(
        URL(string: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")!
    )
    static let liveAudioMP3 = Media.url(
        URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
    )

    static let dvrAudioHLS = Media.url(
        URL(string: "https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")!
    )

    // Apple streams from https://developer.apple.com/streaming/examples/
    static let appleBasic_4_3_HLS = Media.url(
        URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!
    )
    static let appleBasic_16_9_TS_HLS = Media.url(
        URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
    )
    static let appleAdvanced_16_9_TS_HLS = Media.url(
        URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    )
    static let appleAdvanced_16_9_fMP4_HLS = Media.url(
        URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Media.url(
        URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!
    )

    static let onDemandVideoLocalHLS = Media.url(URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
}

// MARK: URN-based medias

enum MediaURN {
    static let onDemandHorizontalVideo = Media.urn("urn:rts:video:6820736")
    static let onDemandSquareVideo = Media.urn("urn:rts:video:8393241")
    static let onDemandVerticalVideo = Media.urn("urn:rts:video:8412286")

    static let tokenProtectedVideo = Media.urn("urn:swisstxt:video:srf:1718849")
    static let superfluousTokenProtectedVideo = Media.urn("urn:rsi:video:15838291")
    static let drmProtectedVideo = Media.urn("urn:rts:video:13584080")

    static let liveVideo = Media.urn("urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    static let dvrVideo = Media.urn("urn:rts:video:3608506")

    static let dvrAudio = Media.urn("urn:rts:audio:3262363")
    static let onDemandAudio = Media.urn("urn:rsi:audio:8833144")

    static let expired = Media.urn("urn:rts:video:13382911")
    static let unknown = Media.urn("urn:srf:video:unknown")
}

// MARK: Unbuffered URL-based medias

enum UnbufferedMediaURL {
    static let liveVideo = Media.unbufferedUrl(
        URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
    )
    static let onDemandAudio = Media.unbufferedUrl(
        URL(string: "https://rts-aod-dd.akamaized.net/ww/13432709/2be967ad-e8a5-33c3-8560-83702436fb2e.mp3")!
    )
    static let liveAudio = Media.unbufferedUrl(
        URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
    )
}

// MARK: Playlists

enum MediaURLPlaylist {
    static let videos: [Media] = [
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444390/f1b478f7-2ae9-3166-94b9-c5d5fe9610df/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444333/feb1d08d-e62c-31ff-bac9-64c0a7081612/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444466/2787e520-412f-35fb-83d7-8dbb31b5c684/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444447/c1d17174-ad2f-31c2-a084-846a9247fd35/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444352/32145dc0-b5f8-3a14-ae11-5fc6e33aaaa4/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444409/23f808a4-b14a-3d3e-b2ed-fa1279f6cf01/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444371/3f26467f-cd97-35f4-916f-ba3927445920/master.m3u8")!),
        .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13444428/857d97ef-0b8e-306e-bf79-3b13e8c901e4/master.m3u8")!)
    ]
}

enum MediaURNPlaylist {
    static let videos: [Media] = [
        .urn("urn:rts:video:13444390"),
        .urn("urn:rts:video:13444333"),
        .urn("urn:rts:video:13444466"),
        .urn("urn:rts:video:13444447"),
        .urn("urn:rts:video:13444352"),
        .urn("urn:rts:video:13444409"),
        .urn("urn:rts:video:13444371"),
        .urn("urn:rts:video:13444428")
    ]
    static let longVideos: [Media] = [
        .urn("urn:rts:video:13588169"),
        .urn("urn:rts:video:13555428"),
        .urn("urn:rts:video:13529000"),
        .urn("urn:rts:video:13471319"),
        .urn("urn:rts:video:13446843"),
        .urn("urn:rts:video:13403392"),
        .urn("urn:rts:video:13387184"),
        .urn("urn:rts:video:13296253")
    ]
    static let videosWithErrors: [Media] = [
        .urn("urn:rts:video:13444390"),
        .urn("urn:rts:video:unknown"),
        .urn("urn:rts:video:13444466")
    ]
    static let tokenProtectedVideos: [Media] = [
        .urn("urn:swisstxt:video:srf:1718849"),
        .urn("urn:swisstxt:video:srf:1718855"),
        .urn("urn:swisstxt:video:srf:1718848"),
        .urn("urn:swisstxt:video:srf:1718854"),
        .urn("urn:swisstxt:video:srf:1718861"),
        .urn("urn:swisstxt:video:srf:1718866"),
        .urn("urn:swisstxt:video:srf:1718860"),
        .urn("urn:swisstxt:video:srf:1718867")
    ]
    static let drmProtectedVideos: [Media] = [
        .urn("urn:rts:video:13584080"),
        .urn("urn:rts:video:13574265"),
        .urn("urn:rts:video:13574256"),
        .urn("urn:rts:video:13564934"),
        .urn("urn:rts:video:13556916"),
        .urn("urn:rts:video:13556347"),
        .urn("urn:rts:video:13556278"),
        .urn("urn:rts:video:13556106")
    ]
    static let audios: [Media] = [
        .urn("urn:rts:audio:13605286"),
        .urn("urn:rts:audio:13598743"),
        .urn("urn:rts:audio:13579611"),
        .urn("urn:rts:audio:13605216")
    ]
}

// MARK: Types

enum Media: Hashable {
    case empty
    case url(URL)
    case unbufferedUrl(URL)
    case urn(String)

    var playerItem: PlayerItem? {
        switch self {
        case .empty:
            return nil
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
