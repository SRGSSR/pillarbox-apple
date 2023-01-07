//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Foundation
import Player

enum URLTemplate {
    static let onDemandVideoHLS = Template(
        title: "Switzerland says sorry! The fondue invasion",
        description: "VOD - HLS",
        type: .url(
            URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!
        )
    )
    static let shortOnDemandVideoHLS = Template(
        title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
        description: "VOD - HLS (short)",
        type: .url(
            URL(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!
        )
    )

    static let onDemandVideoMP4 = Template(
        title: "The dig",
        description: "VOD - MP4",
        type: .url(
            URL(string: "https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")!
        )
    )

    static let liveVideoHLS = Template(
        title: "Couleur 3 en vidéo (live)",
        description: "Video livestream - HLS",
        type: .url(
            URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
        )
    )
    static let dvrVideoHLS = Template(
        title: "Couleur 3 en vidéo (DVR)",
        description: "Video livestream with DVR - HLS",
        type: .url(
            URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")!
        )
    )
    static let liveTimestampVideoHLS = Template(
        title: "Tageschau",
        description: "Video livestream with DVR and timestamps - HLS",
        type: .url(
            URL(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!
        )
    )

    static let onDemandAudioMP3 = Template(
        title: "On en parle",
        description: "AOD - MP3",
        type: .url(
            URL(string: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")!
        )
    )
    static let liveAudioMP3 = Template(
        title: "Couleur 3 (live)",
        description: "Audio livestream - MP3",
        type: .url(
            URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
        )
    )

    static let dvrAudioHLS = Template(
        title: "Couleur 3 (DVR)",
        description: "Audio livestream - HLS",
        type: .url(
            URL(string: "https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")!
        )
    )

    // Apple streams from https://developer.apple.com/streaming/examples/
    static let appleBasic_4_3_HLS = Template(
        title: "Apple Basic 4:3",
        description: "4x3 aspect ratio, H.264 @ 30Hz",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!
        )
    )
    static let appleBasic_16_9_TS_HLS = Template(
        title: "Apple Basic 16:9",
        description: "16x9 aspect ratio, H.264 @ 30Hz",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        )
    )
    static let appleAdvanced_16_9_TS_HLS = Template(
        title: "Apple Advanced 16:9 (TS)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
        )
    )
    static let appleAdvanced_16_9_fMP4_HLS = Template(
        title: "Apple Advanced 16:9 (fMP4)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
        )
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Template(
        title: "Apple Advanced 16:9 (HEVC/H.264)",
        description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
        type: .url(
            URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!
        )
    )

    static let onDemandVideoLocalHLS = Template(
        title: "Nyan cat",
        description: "Stream served locally",
        type: .url(
            URL(string: "http://localhost:8123/on_demand/master.m3u8")!
        )
    )

    static let unknown = Template(title: "Unknown URL", type: .url(URL(string: "http://localhost:8123/unavailable/master.m3u8")!))
}

enum URNTemplate {
    static let onDemandHorizontalVideo = Template(
        title: "Horizontal video",
        type: .urn("urn:rts:video:6820736")
    )
    static let onDemandSquareVideo = Template(
        title: "Square video",
        type: .urn("urn:rts:video:8393241")
    )
    static let onDemandVerticalVideo = Template(
        title: "Vertical video",
        type: .urn("urn:rts:video:8412286")
    )
    static let tokenProtectedVideo = Template(
        title: "Ski alpin, Slalom Messieurs",
        description: "Token-protected video",
        type: .urn("urn:swisstxt:video:rts:1749666")
    )
    static let superfluouslyTokenProtectedVideo = Template(
        title: "Telegiornale flash",
        description: "Superfluously token-protected video",
        type: .urn("urn:rsi:video:15916771")
    )
    static let drmProtectedVideo = Template(
        title: "Top Models 8870",
        description: "DRM-protected video",
        type: .urn("urn:rts:video:13639837")
    )
    static let liveVideo = Template(
        title: "SRF 1",
        description: "Live video",
        type: .urn("urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    )
    static let dvrVideo = Template(
        title: "RTS 1",
        description: "DVR video livestream",
        type: .urn("urn:rts:video:3608506")
    )
    static let dvrAudio = Template(
        title: "Couleur 3 (DVR)",
        description: "DVR audio livestream",
        type: .urn("urn:rts:audio:3262363")
    )
    static let onDemandAudio = Template(
        title: "Il lavoro di TerraProject per una fotografia documentaria",
        description: "On-demand audio stream",
        type: .urn("urn:rsi:audio:8833144")
    )
    static let expired = Template(
        title: "Expired URN",
        description: "Content that is not available anymore",
        type: .urn("urn:rts:video:13382911")
    )
    static let unknown = Template(
        title: "Unknown URN",
        description: "Content that does not exist",
        type: .urn("urn:srf:video:unknown")
    )
}

enum UnbufferedURLTemplate {
    static let liveVideo = Template(
        title: "Couleur 3 en direct",
        description: "Live video",
        type: .unbufferedUrl(
            URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
        )
    )
    static let onDemandAudio = Template(
        title: "Forum",
        description: "On-demand audio stream",
        type: .unbufferedUrl(
            URL(string: "https://rts-aod-dd.akamaized.net/ww/13432709/2be967ad-e8a5-33c3-8560-83702436fb2e.mp3")!
        )
    )
    static let liveAudio = Template(
        title: "Couleur 3 en direct",
        description: "Audio livestream",
        type: .unbufferedUrl(
            URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
        )
    )
}

struct Template: Hashable {
    let title: String
    let description: String?
    let type: Media.`Type`

    init(title: String, description: String? = nil, type: Media.`Type`) {
        self.title = title
        self.description = description
        self.type = type
    }

    static func medias(from templates: [Template]) -> [Media] {
        templates.map { Media(from: $0) }
    }
}
