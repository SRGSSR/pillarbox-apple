//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

private let kAppleImageUrl = URL("https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200")
private let kBitmovinImageUrl = URL("""
    https://img.redbull.com/images/c_crop,w_3840,h_1920,x_0,y_0,f_auto,q_auto/c_scale,w_1200/redbullcom/tv/FO-1MR39KNMH2111/fo-1mr39knmh2111-featuremedia
    """)
private let kUnifiedStreamingImageUrl1 = URL("https://mango.blender.org/wp-content/gallery/4k-renders/01_thom_celia_bridge.jpg")
private let kUnifiedStreamingImageUrl2 = URL("https://website-storage.unified-streaming.com/images/_1200x630_crop_center-center_none/default-facebook.png")

// Stream sources:
//   - Apple: https://developer.apple.com/streaming/examples/
//   - Unified Streaming: https://demo.unified-streaming.com/k8s/features/stable/#!/hls
//   - BBC: https://rdmedia.bbc.co.uk/testcard/simulcast/
// swiftlint:disable:next type_body_length
enum URLMedia {
    static let onDemandVideoHLS = Media(
        title: "Sacha part à la rencontre d'univers atypiques",
        subtitle: "VOD - HLS",
        imageUrl: "https://www.rts.ch/2024/06/13/11/34/14970435.image/16x9",
        type: .url("https://rts-vod-amd.akamaized.net/ww/14970442/96fc7429-64c1-34b0-8c05-62cf114695ac/master.m3u8")
    )
    static let shortOnDemandVideoHLS = Media(
        title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
        subtitle: "VOD - HLS (short)",
        imageUrl: "https://www.rts.ch/2022/08/18/12/38/13317144.image/16x9",
        type: .url("https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")
    )
    static let onDemandVideoMP4 = Media(
        title: "Swiss wheelchair athlete wins top award",
        subtitle: "VOD - MP4",
        imageUrl: "https://cdn.prod.swi-services.ch/video-delivery/images/94f5f5d1-5d53-4336-afda-9198462c45d9/_.1hAGinujJ.yERGrrGNzBGCNSxmhKZT/16x9",
        type: .url("https://cdn.prod.swi-services.ch/video-projects/94f5f5d1-5d53-4336-afda-9198462c45d9/localised-videos/ENG/renditions/ENG.mp4")
    )
    static let liveVideoHLS = Media(
        title: "Couleur 3 en vidéo (live)",
        subtitle: "Video livestream - HLS",
        imageUrl: "https://img.rts.ch/audio/2010/image/924h3y-25865853.image?w=640&h=640",
        type: .url("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")
    )
    static let dvrVideoHLS = Media(
        title: "Couleur 3 en vidéo (DVR)",
        subtitle: "Video livestream with DVR - HLS",
        imageUrl: "https://il.srgssr.ch/images/?imageUrl=https%3A%2F%2Fwww.rts.ch%2F2020%2F05%2F18%2F14%2F20%2F11333286.image%2F16x9&format=jpg&width=960",
        type: .url("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")
    )
    static let liveTimestampVideoHLS = Media(
        title: "Tageschau",
        subtitle: "Video livestream with DVR and timestamps - HLS",
        imageUrl: "https://images.tagesschau.de/image/89045d82-5cd5-46ad-8f91-73911add30ee/AAABh3YLLz0/AAABibBx2rU/20x9-1280/tagesschau-logo-100.jpg",
        type: .url("https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")
    )
    static let onDemandAudioMP3 = Media(
        title: "On en parle",
        subtitle: "AOD - MP3",
        imageUrl: "https://www.rts.ch/2023/09/28/17/49/11872957.image?w=624&h=351",
        type: .url("https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")
    )
    static let liveAudioMP3 = Media(
        title: "Couleur 3 (live)",
        subtitle: "Audio livestream - MP3",
        imageUrl: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=640&h=640",
        type: .url("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    )
    static let startTimeVideo = Media(
        title: "Apple Basic 16:9",
        subtitle: "16x9 aspect ratio, H.264 @ 30Hz",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"),
        startTime: .init(value: 600, timescale: 1)
    )
    static let timeRangesVideo = Media(
        title: "Bip",
        subtitle: "Content with opening and closing credits",
        imageUrl: "https://www.rts.ch/2023/05/01/10/22/10253916.image/16x9",
        type: .url("https://rts-vod-amd.akamaized.net/ch/10004745/c0547249-1328-308d-a392-47e0b86968bb/master.m3u8"),
        timeRanges: [
            .init(kind: .credits(.opening), start: .zero, end: .init(value: 9, timescale: 1)),
            .init(kind: .credits(.closing), start: .init(value: 163, timescale: 1), end: .init(value: 183_680, timescale: 1000))
        ]
    )
    static let blockedTimeRangesVideo = Media(
        title: "Apple Basic 16:9",
        subtitle: "Content with blocked time ranges",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"),
        timeRanges: [
            .init(kind: .blocked, start: .zero, end: .init(value: 300, timescale: 1)),
            .init(kind: .blocked, start: .init(value: 600, timescale: 1), end: .init(value: 900, timescale: 1)),
            .init(kind: .blocked, start: .init(value: 700, timescale: 1), end: .init(value: 1200, timescale: 1))
        ]
    )
    static let appleBasic_4_3_HLS = Media(
        title: "Apple Basic 4:3",
        subtitle: "4x3 aspect ratio, H.264 @ 30Hz",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
    )
    static let appleBasic_16_9_TS_HLS = Media(
        title: "Apple Basic 16:9",
        subtitle: "16x9 aspect ratio, H.264 @ 30Hz",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")
    )
    static let appleAdvanced_16_9_TS_HLS = Media(
        title: "Apple Advanced 16:9 (TS)",
        subtitle: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")
    )
    static let appleAdvanced_16_9_fMP4_HLS = Media(
        title: "Apple Advanced 16:9 (fMP4)",
        subtitle: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Media(
        title: "Apple Advanced 16:9 (HEVC/H.264)",
        subtitle: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
        imageUrl: kAppleImageUrl,
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")
    )
    static let appleWWDCKeynote2023 = Media(
        title: "Apple WWDC Keynote 2023",
        imageUrl: "https://www.apple.com/v/apple-events/home/ac/images/overview/recent-events/gallery/jun-2023__cjqmmqlyd21y_large_2x.jpg",
        type: .url("https://events-delivery.apple.com/0105cftwpxxsfrpdwklppzjhjocakrsk/m3u8/vod_index-PQsoJoECcKHTYzphNkXohHsQWACugmET.m3u8")
    )
    static let appleDolbyAtmos = Media(
        title: "Apple Dolby Atmos",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/-6farfCY0YClFd7-z_qZbA/1000x563.jpg",
        type: .url("https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")
    )
    static let appleTvMorningShowSeason1Trailer = Media(
        title: "The Morning Show - My Way: Season 1",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/cZUkXfqYmSy57DBI5TiTMg/1000x563.jpg",
        // swiftlint:disable:next line_length
        type: .url("https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1522121579&isExternal=true&brandId=tvs.sbd.4000&id=518077009&l=en-GB&aec=UHD")
    )
    static let appleTvMorningShowSeason2Trailer = Media(
        title: "The Morning Show - Change: Season 2",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/IxmmS1rQ7ouO-pKoJsVpGw/1000x563.jpg",
        // swiftlint:disable:next line_length
        type: .url("https://play-edge.itunes.apple.com/WebObjects/MZPlayLocal.woa/hls/subscription/playlist.m3u8?cc=CH&svcId=tvs.vds.4021&a=1568297173&isExternal=true&brandId=tvs.sbd.4000&id=518034010&l=en-GB&aec=UHD")
    )
    static let uhdVideoHLS = Media(
        title: "Brain Farm Skate Phantom Flex",
        subtitle: "4K video",
        imageUrl: "https://i.ytimg.com/vi/d4_96ZWu3Vk/maxresdefault.jpg",
        type: .url("https://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8")
    )
    static let onDemandVideoLocalHLS = Media(
        title: "Test video pattern",
        subtitle: "Stream served locally",
        type: .url("http://localhost:8123/simple/on_demand/master.m3u8")
    )
    static let unknown = Media(
        title: "Unknown URL",
        subtitle: "Content that does not exist",
        type: .url("http://localhost:8123/simple/unavailable/master.m3u8")
    )
    static let unavailableMp3 = Media(
        title: "Unavailable MP3",
        subtitle: "MP3 that does not exist",
        type: .url("http://localhost:8123/simple/unavailable.mp3")
    )
    static let unauthorized = Media(
        title: "Unauthorized URL",
        subtitle: "Content which cannot be accessed",
        type: .url("https://httpbin.org/status/403")
    )
    static let bitmovinOnDemandMultipleTracks = Media(
        title: "Multiple subtitles and audio tracks",
        imageUrl: "https://durian.blender.org/wp-content/uploads/2010/06/05.8b_comp_000272.jpg",
        type: .url("https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
    )
    static let bitmovinOnDemand_4K_HEVC = Media(
        title: "4K, HEVC",
        imageUrl: "https://peach.blender.org/wp-content/uploads/bbb-splash.png",
        type: .url("https://cdn.bitmovin.com/content/encoding_test_dash_hls/4k/hls/4k_profile/master.m3u8")
    )
    static let bitmovinOnDemandSingleAudio = Media(
        title: "VoD, single audio track",
        imageUrl: kBitmovinImageUrl,
        type: .url("https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")
    )
    static let bitmovinOnDemandAES128 = Media(
        title: "AES-128",
        imageUrl: kBitmovinImageUrl,
        type: .url("https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8")
    )
    static let bitmovinOnDemandProgressive = Media(
        title: "AVC Progressive",
        imageUrl: kBitmovinImageUrl,
        type: .url("https://bitmovin-a.akamaihd.net/content/MI201109210084_1/MI201109210084_mpeg-4_hd_high_1080p25_10mbits.mp4")
    )
    static let unifiedStreamingOnDemand_fMP4 = Media(
        title: "Fragmented MP4",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")
    )
    static let unifiedStreamingOnDemandKeyRotation = Media(
        title: "Key Rotation",
        imageUrl: kUnifiedStreamingImageUrl2,
        type: .url("https://demo.unified-streaming.com/k8s/keyrotation/stable/keyrotation/keyrotation.isml/.m3u8")
    )
    static let unifiedStreamingOnDemandAlternateAudio = Media(
        title: "Alternate audio language",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8")
    )
    static let unifiedStreamingOnDemandAudioOnly = Media(
        title: "Audio only",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8?filter=(type!=%22video%22)")
    )
    static let unifiedStreamingOnDemandTrickplay = Media(
        title: "Trickplay",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/no-handler-origin/tears-of-steel/tears-of-steel-trickplay.m3u8")
    )
    static let unifiedStreamingOnDemandLimitedBandwidth = Media(
        title: "Limiting bandwidth use",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?max_bitrate=800000")
    )
    static let unifiedStreamingOnDemandDynamicTrackSelection = Media(
        title: "Dynamic Track Selection",
        imageUrl: kUnifiedStreamingImageUrl1,
        // swiftlint:disable:next line_length
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?filter=%28type%3D%3D%22audio%22%26%26systemBitrate%3C100000%29%7C%7C%28type%3D%3D%22video%22%26%26systemBitrate%3C1024000%29")
    )
    static let unifiedStreamingPureLive = Media(
        title: "Pure live",
        imageUrl: kUnifiedStreamingImageUrl2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8")
    )
    static let unifiedStreamingTimeshift = Media(
        title: "Timeshift (5 minutes)",
        imageUrl: kUnifiedStreamingImageUrl2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?time_shift=300")
    )
    static let unifiedStreamingLiveAudio = Media(
        title: "Live audio",
        imageUrl: kUnifiedStreamingImageUrl2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?filter=(type!=%22video%22)")
    )
    static let unifiedStreamingPureLiveScte35 = Media(
        title: "Pure live (scte35)",
        imageUrl: kUnifiedStreamingImageUrl2,
        type: .url("https://demo.unified-streaming.com/k8s/live/stable/scte35.isml/.m3u8")
    )
    static let unifiedStreamingOnDemand_fMP4_Clear = Media(
        title: "fMP4, clear",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-fmp4.ism/.m3u8")
    )
    static let unifiedStreamingOnDemand_fMP4_HEVC_4K = Media(
        title: "fMP4, HEVC 4K",
        imageUrl: kUnifiedStreamingImageUrl1,
        type: .url("https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-hevc.ism/.m3u8")
    )
    static let bbcTestCard_Audio_Video_AVC = Media(
        title: "Audio and AVC video",
        subtitle: "All representations in all languages",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-full.m3u8")
    )
    static let bbcTestCard_Audio_Video_AVC_TVs = Media(
        title: "Audio and AVC video",
        subtitle: "Representations for Connected TVs in all languages",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-ctv.m3u8")
    )
    static let bbcTestCard_Audio_Video_AVC_Mobile = Media(
        title: "Audio and AVC video",
        subtitle: "Representations for Mobile Devices in all languages",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-mobile.m3u8")
    )
    static let bbcTestCard_Audio_Video_HEVC_TVs = Media(
        title: "Audio and HEVC video",
        subtitle: "Representations for Connected TVs in all languages",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/hevc-ctv.m3u8")
    )
    static let bbcTestCard_Audio_HE_LC_AAC_en = Media(
        title: "Audio only",
        subtitle: "HE and LC AAC Stereo in English",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-en.m3u8")
    )
    static let bbcTestCard_Audio_HE_AAC_en = Media(
        title: "Audio only",
        subtitle: "HE-AAC Stereo in English",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-he-en.m3u8")
    )
    static let bbcTestCard_Audio_AAC_LC_en = Media(
        title: "Audio only",
        subtitle: "AAC-LC Stereo in English",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-lc-en.m3u8")
    )
    static let bbcTestCard_Audio_AAC_LC_de = Media(
        title: "Audio only",
        subtitle: "AAC-LC Stereo in German",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-lc-de.m3u8")
    )
    static let bbcTestCard_Audio_AAC_LC_fr = Media(
        title: "Audio only",
        subtitle: "AAC-LC Stereo in French",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-lc-fr.m3u8")
    )
    static let bbcTestCard_Audio_HE_LC_AAC_all = Media(
        title: "Audio only",
        subtitle: "HE and LC AAC Stereo in all languages",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-multilang.m3u8")
    )
    static let bbcTestCard_Audio_AAC_LC_surround_en = Media(
        title: "Audio only",
        subtitle: "AAC-LC Surround (4 active channels) in English",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-surround-en.m3u8")
    )
    static let bbcTestCard_Audio_AAC_LC_surround_de = Media(
        title: "Audio only",
        subtitle: "AAC-LC Surround (4 active channels) in German",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-surround-de.m3u8")
    )
    static let bbcTestCard_Audio_AAC_LC_surround_fr = Media(
        title: "Audio only",
        subtitle: "AAC-LC Surround (4 active channels) in French",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-surround-fr.m3u8")
    )
    static let bbcTestCard_Audio_FLAC_en = Media(
        title: "Audio only",
        subtitle: "FLAC Stereo in English",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/radio-flac-en.m3u8")
    )
    static let bbcTestCard_Restricted_Stereo_TVs = Media(
        title: "Restricted manifests",
        subtitle: "Connected TV representations with only stereo audio",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-ctv-stereo-en.m3u8")
    )
    static let bbcTestCard_Restricted_HEVC_Stereo_TVs = Media(
        title: "Restricted manifests",
        subtitle: "Connected TV representations (HEVC) with only stereo audio",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/hevc-ctv-stereo-en.m3u8")
    )
    static let bbcTestCard_Restricted_NoSubtitles_TVs = Media(
        title: "Restricted manifests",
        subtitle: "Connected TV representations with no subtitles",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-ctv-no_subs-en.m3u8")
    )
    static let bbcTestCard_Single_192x108p25_AAC_LC = Media(
        title: "Single representations",
        subtitle: "192x108p25, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-192x108p25-en.m3u8")
    )
    static let bbcTestCard_Single_256x144p25_AAC_LC = Media(
        title: "Single representations",
        subtitle: "256x144p25, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-256x144p25-en.m3u8")
    )
    static let bbcTestCard_Single_384x216p25_AAC_LC = Media(
        title: "Single representations",
        subtitle: "384x216p25, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-384x216p25-en.m3u8")
    )
    static let bbcTestCard_Single_512x288p25_AAC_LC = Media(
        title: "Single representations",
        subtitle: "512x288p25, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-512x288p25-en.m3u8")
    )
    static let bbcTestCard_Single_704x396p25_AAC_LC = Media(
        title: "Single representations",
        subtitle: "704x396p25, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-704x396p25-en.m3u8")
    )
    static let bbcTestCard_Single_704x396p50_AAC_LC = Media(
        title: "Single representations",
        subtitle: "704x396p50, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-704x396p50-en.m3u8")
    )
    static let bbcTestCard_Single_896x504p25_AAC_LC = Media(
        title: "Single representations",
        subtitle: "896x504p25, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-896x504p25-en.m3u8")
    )
    static let bbcTestCard_Single_960x540p50_AAC_LC = Media(
        title: "Single representations",
        subtitle: "960x540p50, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-960x540p50-en.m3u8")
    )
    static let bbcTestCard_Single_1280x720p50_AAC_LC = Media(
        title: "Single representations",
        subtitle: "1280x720p50, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-1280x720p50-en.m3u8")
    )
    static let bbcTestCard_Single_1920x1080p50_AAC_LC = Media(
        title: "Single representations",
        subtitle: "1920x1080p50, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-128kbps-1920x1080p50-en.m3u8")
    )
    static let bbcTestCard_Single_1280x720p50_HE_AAC = Media(
        title: "Single representations",
        subtitle: "1280x720p50, 96kbps HE-AAC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-single-96kbps-1280x720p50-en.m3u8")
    )
    static let bbcTestCard_Single_1280x720p50_HEVC_AAC_LC = Media(
        title: "Single representations",
        subtitle: "1280x720p50 HEVC, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/hevc-single-128kbps-1280x720p50-en.m3u8")
    )
    static let bbcTestCard_Single_1920x1080p50_HEVC_AAC_LC = Media(
        title: "Single representations",
        subtitle: "1920x1080p50 HEVC, 128kbps AAC-LC",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/hevc-single-128kbps-1920x1080p50-en.m3u8")
    )
    static let bbcTestCard_NoTLS_HTTP_TVs = Media(
        title: "Relative or HTTP only BaseURLs",
        subtitle: "Connected TV representations - using HTTP",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-ctv-en-http.m3u8")
    )
    static let bbcTestCard_NoTLS_Relative_TVs = Media(
        title: "Relative or HTTP only BaseURLs",
        subtitle: "Connected TV representations - using relative paths",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-ctv-en-rel.m3u8")
    )
    static let bbcTestCard_NoTLS_Relative_Mobile = Media(
        title: "Relative or HTTP only BaseURLs",
        subtitle: "Mobile resolutions with relative Base URLs    ",
        type: .url("https://rdmedia.bbc.co.uk/testcard/simulcast/manifests/avc-mobile-en-rel.m3u8")
    )
    static let mux_LowLatency = Media(
        title: "Low-Latency",
        type: .url("https://stream.mux.com/v69RSHhFelSm4701snP22dYz2jICy4E4FUyk02rW4gxRM.m3u8")
    )
    static let bitmovin_360 = Media(
        title: "Bitmovin 360°",
        imageUrl: "https://www.rts.ch/2017/02/24/11/43/8414076.image/16x9",
        type: .monoscopicUrl("https://cdn.bitmovin.com/content/assets/playhouse-vr/m3u8s/105560.m3u8")
    )
}
