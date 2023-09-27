//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

// Apple streams are found at https://developer.apple.com/streaming/examples/
// Unified Streaming streams are found at https://demo.unified-streaming.com/k8s/features/stable/#!/hls
enum URLTemplate {
    static let onDemandVideoHLS = Template(
        title: "Switzerland says sorry! The fondue invasion",
        description: "VOD - HLS",
        type: .url("https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")
    )
    static let shortOnDemandVideoHLS = Template(
        title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
        description: "VOD - HLS (short)",
        type: .url("https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")
    )
    static let onDemandVideoMP4 = Template(
        title: "The dig",
        description: "VOD - MP4",
        type: .url("https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")
    )
    static let liveVideoHLS = Template(
        title: "Couleur 3 en vidéo (live)",
        description: "Video livestream - HLS",
        type: .url("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")
    )
    static let dvrVideoHLS = Template(
        title: "Couleur 3 en vidéo (DVR)",
        description: "Video livestream with DVR - HLS",
        type: .url("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")
    )
    static let liveTimestampVideoHLS = Template(
        title: "Tageschau",
        description: "Video livestream with DVR and timestamps - HLS",
        type: .url("https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")
    )
    static let onDemandAudioMP3 = Template(
        title: "On en parle",
        description: "AOD - MP3",
        type: .url("https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")
    )
    static let liveAudioMP3 = Template(
        title: "Couleur 3 (live)",
        description: "Audio livestream - MP3",
        type: .url("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    )
    static let dvrAudioHLS = Template(
        title: "Couleur 3 (DVR)",
        description: "Audio livestream - HLS",
        type: .url("https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")
    )
    static let appleBasic_4_3_HLS = Template(
        title: "Apple Basic 4:3",
        description: "4x3 aspect ratio, H.264 @ 30Hz",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
    )
    static let appleBasic_16_9_TS_HLS = Template(
        title: "Apple Basic 16:9",
        description: "16x9 aspect ratio, H.264 @ 30Hz",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")
    )
    static let appleAdvanced_16_9_TS_HLS = Template(
        title: "Apple Advanced 16:9 (TS)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")
    )
    static let appleAdvanced_16_9_fMP4_HLS = Template(
        title: "Apple Advanced 16:9 (fMP4)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Template(
        title: "Apple Advanced 16:9 (HEVC/H.264)",
        description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")
    )
    static let appleWWDCKeynote2023 = Template(
        title: "Apple WWDC Keynote 2023",
        type: .url("https://events-delivery.apple.com/0105cftwpxxsfrpdwklppzjhjocakrsk/m3u8/vod_index-PQsoJoECcKHTYzphNkXohHsQWACugmET.m3u8")
    )
    static let appleDolbyAtmos = Template(
        title: "Apple Dolby Atmos",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")
    )
    static let appleTvMorningShowSeason1Trailer = Template(
        title: "The Morning Show - My Way: Season 1",
        // swiftlint:disable:next line_length
        type: .url("https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1522121579&isExternal=true&brandId=tvs.sbd.4000&id=518077009&l=en-GB&aec=UHD")
    )
    static let appleTvMorningShowSeason2Trailer = Template(
        title: "The Morning Show - Change: Season 2",
        // swiftlint:disable:next line_length
        type: .url("https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1568297173&isExternal=true&brandId=tvs.sbd.4000&id=518034010&l=en-GB&aec=UHD")
    )
    static let uhdVideoHLS = Template(
        title: "Brain Farm Skate Phantom Flex",
        description: "4K video",
        type: .url("http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8")
    )
    static let onDemandVideoLocalHLS = Template(
        title: "Test video pattern",
        description: "Stream served locally",
        type: .url("http://localhost:8123/simple/on_demand/master.m3u8")
    )
    static let unknown = Template(
        title: "Unknown URL",
        type: .url("http://localhost:8123/simple/unavailable/master.m3u8")
    )
    static let bitmovinOnDemandMultipleTracks = Template(
        title: "Multiple subtitles and audio tracks",
        type: .url("https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    )
    static let bitmovinOnDemand_4K_HEVC = Template(
        title: "4K, HEVC",
        type: .url("https://cdn.bitmovin.com/content/encoding_test_dash_hls/4k/hls/4k_profile/master.m3u8")
    )
    static let bitmovinOnDemandSingleAudio = Template(
        title: "VoD, single audio track",
        type: .url("https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
    )
    static let bitmovinOnDemandAES128 = Template(
        title: "AES-128",
        type: .url("https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8")
    )
    static let bitmovinOnDemandProgressive = Template(
        title: "AVC Progressive",
        type: .url("https://bitmovin-a.akamaihd.net/content/MI201109210084_1/MI201109210084_mpeg-4_hd_high_1080p25_10mbits.mp4")
    )
    static let unifiedStreamingOnDemand_fMP4 = Template(
        title: "Fragmented MP4",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")
    )
    static let unifiedStreamingOnDemandKeyRotation = Template(
        title: "Key Rotation",
        type: .url("https://demo.unified-streaming.com/k8s/keyrotation/stable/keyrotation/keyrotation.isml/.m3u8")
    )
    static let unifiedStreamingOnDemandAlternateAudio = Template(
        title: "Alternate audio language",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8")
    )
    static let unifiedStreamingOnDemandAudioOnly = Template(
        title: "Audio only",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8?filter=(type!=%22video%22)")
    )
    static let unifiedStreamingOnDemandTrickplay = Template(
        title: "Trickplay",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/no-handler-origin/tears-of-steel/tears-of-steel-trickplay.m3u8")
    )
    static let unifiedStreamingOnDemandLimitedBandwidth = Template(
        title: "Limiting bandwidth use",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?max_bitrate=800000")
    )
    static let unifiedStreamingOnDemandDynamicTrackSelection = Template(
        title: "Dynamic Track Selection",
        // swiftlint:disable:next line_length
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?filter=%28type%3D%3D%22audio%22%26%26systemBitrate%3C100000%29%7C%7C%28type%3D%3D%22video%22%26%26systemBitrate%3C1024000%29")
    )
    static let unifiedStreamingPureLive = Template(
        title: "Pure live",
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8")
    )
    static let unifiedStreamingTimeshift = Template(
        title: "Timeshift (5 minutes)",
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?time_shift=300")
    )
    static let unifiedStreamingLiveAudio = Template(
        title: "Live audio",
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?filter=(type!=%22video%22)")
    )
    static let unifiedStreamingPureLiveScte35 = Template(
        title: "Pure live (scte35)",
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/scte35.isml/.m3u8")
    )
    static let unifiedStreamingOnDemand_fMP4_Clear = Template(
        title: "fMP4, clear",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-fmp4.ism/.m3u8")
    )
    static let unifiedStreamingOnDemand_fMP4_HEVC_4K = Template(
        title: "fMP4, HEVC 4K",
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-hevc.ism/.m3u8")
    )
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
        type: .urn("urn:rts:video:13444390")
    )
    static let onDemandVideo = Template(
        title: "A bon entendeur",
        type: .urn("urn:rts:video:14080915")
    )
    static let liveVideo = Template(
        title: "RSI 1",
        description: "Live video",
        type: .urn("urn:rsi:video:livestream_La1")
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
        description: "Live video (unbuffered)",
        type: .unbufferedUrl("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")
    )
    static let liveAudio = Template(
        title: "Couleur 3 en direct",
        description: "Audio livestream (unbuffered)",
        type: .unbufferedUrl("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
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

    static func medias(from templates: [Self]) -> [Media] {
        templates.map { Media(from: $0) }
    }
}

extension Template {
    static func playerItem(from template: Template) -> AVPlayerItem? {
        switch template.type {
        case let .url(url):
            return AVPlayerItem(url: url)
        case let .unbufferedUrl(url):
            let item = AVPlayerItem(url: url)
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
            return item
        case .urn, .youTube:
            return nil
        }
    }
}
