//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private let kAppleImage = URL("https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200")
private let kBitmovinImage = URL("""
    https://img.redbull.com/images/c_crop,w_3840,h_1920,x_0,y_0,f_auto,q_auto/c_scale,w_1200/redbullcom/tv/FO-1MR39KNMH2111/fo-1mr39knmh2111-featuremedia
    """)
private let kThreeSixtyImage = URL("https://www.rts.ch/2017/02/24/11/43/8414076.image/16x9")
private let kUnifiedStreamingImage1 = URL("https://mango.blender.org/wp-content/gallery/4k-renders/01_thom_celia_bridge.jpg")
private let kUnifiedStreamingImage2 = URL("https://website-storage.unified-streaming.com/images/_1200x630_crop_center-center_none/default-facebook.png")

// Apple streams are found at https://developer.apple.com/streaming/examples/
// Unified Streaming streams are found at https://demo.unified-streaming.com/k8s/features/stable/#!/hls
enum URLTemplate {
    static let onDemandVideoHLS = Template(
        title: "Switzerland says sorry! The fondue invasion",
        description: "VOD - HLS",
        image: "https://www.swissinfo.ch/srgscalableimage/47603560/16x9",
        type: .url("https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")
    )
    static let shortOnDemandVideoHLS = Template(
        title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
        description: "VOD - HLS (short)",
        image: "https://www.rts.ch/2022/08/18/12/38/13317144.image/16x9",
        type: .url("https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")
    )
    static let onDemandVideoMP4 = Template(
        title: "The dig",
        description: "VOD - MP4",
        // swiftlint:disable:next line_length
        image: "https://www.swissinfo.ch/resource/image/47686506/landscape_ratio3x2/280/187/347ee14103b1b86184659b2fd04c69ba/8C028539EC620EFACC0BF2F61591E2F8/img_8527.jpg",
        type: .url("https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")
    )
    static let liveVideoHLS = Template(
        title: "Couleur 3 en vidéo (live)",
        description: "Video livestream - HLS",
        image: "https://img.rts.ch/audio/2010/image/924h3y-25865853.image?w=640&h=640",
        type: .url("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")
    )
    static let dvrVideoHLS = Template(
        title: "Couleur 3 en vidéo (DVR)",
        description: "Video livestream with DVR - HLS",
        image: "https://il.srgssr.ch/images/?imageUrl=https%3A%2F%2Fwww.rts.ch%2F2020%2F05%2F18%2F14%2F20%2F11333286.image%2F16x9&format=jpg&width=960",
        type: .url("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")
    )
    static let liveTimestampVideoHLS = Template(
        title: "Tageschau",
        description: "Video livestream with DVR and timestamps - HLS",
        image: "https://images.tagesschau.de/image/89045d82-5cd5-46ad-8f91-73911add30ee/AAABh3YLLz0/AAABibBx2rU/20x9-1280/tagesschau-logo-100.jpg",
        type: .url("https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")
    )
    static let onDemandAudioMP3 = Template(
        title: "On en parle",
        description: "AOD - MP3",
        image: "https://www.rts.ch/2023/09/28/17/49/11872957.image?w=624&h=351",
        type: .url("https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")
    )
    static let liveAudioMP3 = Template(
        title: "Couleur 3 (live)",
        description: "Audio livestream - MP3",
        image: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=640&h=640",
        type: .url("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    )
    static let appleBasic_4_3_HLS = Template(
        title: "Apple Basic 4:3",
        description: "4x3 aspect ratio, H.264 @ 30Hz",
        image: kAppleImage,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
    )
    static let appleBasic_16_9_TS_HLS = Template(
        title: "Apple Basic 16:9",
        description: "16x9 aspect ratio, H.264 @ 30Hz",
        image: kAppleImage,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")
    )
    static let appleAdvanced_16_9_TS_HLS = Template(
        title: "Apple Advanced 16:9 (TS)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
        image: kAppleImage,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")
    )
    static let appleAdvanced_16_9_fMP4_HLS = Template(
        title: "Apple Advanced 16:9 (fMP4)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
        image: kAppleImage,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Template(
        title: "Apple Advanced 16:9 (HEVC/H.264)",
        description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
        image: kAppleImage,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")
    )
    static let appleWWDCKeynote2023 = Template(
        title: "Apple WWDC Keynote 2023",
        image: "https://www.apple.com/v/apple-events/home/ac/images/overview/recent-events/gallery/jun-2023__cjqmmqlyd21y_large_2x.jpg",
        type: .url("https://events-delivery.apple.com/0105cftwpxxsfrpdwklppzjhjocakrsk/m3u8/vod_index-PQsoJoECcKHTYzphNkXohHsQWACugmET.m3u8")
    )
    static let appleDolbyAtmos = Template(
        title: "Apple Dolby Atmos",
        image: "https://is1-ssl.mzstatic.com/image/thumb/-6farfCY0YClFd7-z_qZbA/1000x563.jpg",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")
    )
    static let appleTvMorningShowSeason1Trailer = Template(
        title: "The Morning Show - My Way: Season 1",
        image: "https://is1-ssl.mzstatic.com/image/thumb/cZUkXfqYmSy57DBI5TiTMg/1000x563.jpg",
        // swiftlint:disable:next line_length
        type: .url("https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1522121579&isExternal=true&brandId=tvs.sbd.4000&id=518077009&l=en-GB&aec=UHD")
    )
    static let appleTvMorningShowSeason2Trailer = Template(
        title: "The Morning Show - Change: Season 2",
        image: "https://is1-ssl.mzstatic.com/image/thumb/IxmmS1rQ7ouO-pKoJsVpGw/1000x563.jpg",
        // swiftlint:disable:next line_length
        type: .url("https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1568297173&isExternal=true&brandId=tvs.sbd.4000&id=518034010&l=en-GB&aec=UHD")
    )
    static let uhdVideoHLS = Template(
        title: "Brain Farm Skate Phantom Flex",
        description: "4K video",
        image: "https://i.ytimg.com/vi/d4_96ZWu3Vk/maxresdefault.jpg",
        type: .url("http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8")
    )
    static let onDemandVideoLocalHLS = Template(
        title: "Test video pattern",
        description: "Stream served locally",
        type: .url("http://localhost:8123/simple/on_demand/master.m3u8")
    )
    static let unknown = Template(
        title: "Unknown URL",
        description: "Content that does not exist",
        type: .url("http://localhost:8123/simple/unavailable/master.m3u8")
    )
    static let unauthorized = Template(
        title: "Unauthorized URL",
        description: "Content which cannot be accessed",
        type: .url("https://httpbin.org/status/403")
    )
    static let bitmovinOnDemandMultipleTracks = Template(
        title: "Multiple subtitles and audio tracks",
        image: "https://durian.blender.org/wp-content/uploads/2010/06/05.8b_comp_000272.jpg",
        type: .url("https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    )
    static let bitmovinOnDemand_4K_HEVC = Template(
        title: "4K, HEVC",
        image: "https://peach.blender.org/wp-content/uploads/bbb-splash.png",
        type: .url("https://cdn.bitmovin.com/content/encoding_test_dash_hls/4k/hls/4k_profile/master.m3u8")
    )
    static let bitmovinOnDemandSingleAudio = Template(
        title: "VoD, single audio track",
        image: kBitmovinImage,
        type: .url("https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
    )
    static let bitmovinOnDemandAES128 = Template(
        title: "AES-128",
        image: kBitmovinImage,
        type: .url("https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8")
    )
    static let bitmovinOnDemandProgressive = Template(
        title: "AVC Progressive",
        image: kBitmovinImage,
        type: .url("https://bitmovin-a.akamaihd.net/content/MI201109210084_1/MI201109210084_mpeg-4_hd_high_1080p25_10mbits.mp4")
    )
    static let unifiedStreamingOnDemand_fMP4 = Template(
        title: "Fragmented MP4",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")
    )
    static let unifiedStreamingOnDemandKeyRotation = Template(
        title: "Key Rotation",
        image: kUnifiedStreamingImage2,
        type: .url("https://demo.unified-streaming.com/k8s/keyrotation/stable/keyrotation/keyrotation.isml/.m3u8")
    )
    static let unifiedStreamingOnDemandAlternateAudio = Template(
        title: "Alternate audio language",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8")
    )
    static let unifiedStreamingOnDemandAudioOnly = Template(
        title: "Audio only",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8?filter=(type!=%22video%22)")
    )
    static let unifiedStreamingOnDemandTrickplay = Template(
        title: "Trickplay",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/no-handler-origin/tears-of-steel/tears-of-steel-trickplay.m3u8")
    )
    static let unifiedStreamingOnDemandLimitedBandwidth = Template(
        title: "Limiting bandwidth use",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?max_bitrate=800000")
    )
    static let unifiedStreamingOnDemandDynamicTrackSelection = Template(
        title: "Dynamic Track Selection",
        image: kUnifiedStreamingImage1,
        // swiftlint:disable:next line_length
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?filter=%28type%3D%3D%22audio%22%26%26systemBitrate%3C100000%29%7C%7C%28type%3D%3D%22video%22%26%26systemBitrate%3C1024000%29")
    )
    static let unifiedStreamingPureLive = Template(
        title: "Pure live",
        image: kUnifiedStreamingImage2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8")
    )
    static let unifiedStreamingTimeshift = Template(
        title: "Timeshift (5 minutes)",
        image: kUnifiedStreamingImage2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?time_shift=300")
    )
    static let unifiedStreamingLiveAudio = Template(
        title: "Live audio",
        image: kUnifiedStreamingImage2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?filter=(type!=%22video%22)")
    )
    static let unifiedStreamingPureLiveScte35 = Template(
        title: "Pure live (scte35)",
        image: kUnifiedStreamingImage2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/scte35.isml/.m3u8")
    )
    static let unifiedStreamingOnDemand_fMP4_Clear = Template(
        title: "fMP4, clear",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-fmp4.ism/.m3u8")
    )
    static let unifiedStreamingOnDemand_fMP4_HEVC_4K = Template(
        title: "fMP4, HEVC 4K",
        image: kUnifiedStreamingImage1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-hevc.ism/.m3u8")
    )
    static let bitmovin_360 = Template(
        title: "Bitmovin 360°",
        image: kThreeSixtyImage,
        type: .url("https://cdn.bitmovin.com/content/assets/playhouse-vr/m3u8s/105560.m3u8"),
        isMonoscopic: true
    )
}

enum URNTemplate {
    static let onDemandHorizontalVideo = Template(
        title: "Horizontal video",
        image: "https://www.rts.ch/2015/05/28/20/19/6820735.image/16x9",
        type: .urn("urn:rts:video:6820736")
    )
    static let onDemandSquareVideo = Template(
        title: "Square video",
        image: "https://www.rts.ch/2017/02/16/07/08/8393235.image/16x9",
        type: .urn("urn:rts:video:8393241")
    )
    static let onDemandVerticalVideo = Template(
        title: "Vertical video",
        image: "https://www.rts.ch/2022/10/06/17/32/13444380.image/4x5",
        type: .urn("urn:rts:video:13444390")
    )
    static let onDemandVideo = Template(
        title: "A bon entendeur",
        image: "https://www.rts.ch/2023/06/13/21/47/14071626.image/16x9",
        type: .urn("urn:rts:video:14080915")
    )
    static let liveVideo = Template(
        title: "RSI 1",
        description: "Live video",
        image: "https://ws.srf.ch/asset/image/audio/6b100f6e-440c-4bfb-8372-89a0688c533a/EPISODE_IMAGE",
        type: .urn("urn:rsi:video:livestream_La1")
    )
    static let dvrVideo = Template(
        title: "RTS 1",
        description: "DVR video livestream",
        image: "https://www.rts.ch/2023/09/06/14/43/14253742.image/16x9",
        type: .urn("urn:rts:video:3608506")
    )
    static let dvrAudio = Template(
        title: "Couleur 3 (DVR)",
        description: "DVR audio livestream",
        image: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=640&h=640",
        type: .urn("urn:rts:audio:3262363")
    )
    static let gothard_360 = Template(
        title: "Gothard 360°",
        image: kThreeSixtyImage,
        type: .urn("urn:rts:video:8414077"),
        isMonoscopic: true
    )
    static let expired = Template(
        title: "Expired URN",
        description: "Content that is not available anymore",
        image: "https://www.rts.ch/2022/09/20/09/57/13365589.image/16x9",
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
        image: "https://www.rts.ch/2020/05/18/14/20/11333286.image/16x9",
        type: .unbufferedUrl("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")
    )
    static let liveAudio = Template(
        title: "Couleur 3 en direct",
        description: "Audio livestream (unbuffered)",
        image: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=320&h=320",
        type: .unbufferedUrl("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    )
}

struct Template: Hashable {
    let title: String
    let description: String?
    let image: URL?
    let type: Media.`Type`
    let isMonoscopic: Bool

    init(title: String, description: String? = nil, image: URL? = nil, type: Media.`Type`, isMonoscopic: Bool = false) {
        self.title = title
        self.description = description
        self.image = image
        self.type = type
        self.isMonoscopic = isMonoscopic
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
        case .urn:
            return nil
        }
    }
}
