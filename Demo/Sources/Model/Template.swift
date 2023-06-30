//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreBusiness
import Foundation

// Apple streams are found at https://developer.apple.com/streaming/examples/
// Unified Streaming streams are found at https://demo.unified-streaming.com/k8s/features/stable/#!/hls
enum URLTemplate {
    static let onDemandVideoHLS = Template(
        title: "Switzerland says sorry! The fondue invasion",
        description: "VOD - HLS",
        type: .url(.init(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!)
    )
    static let shortOnDemandVideoHLS = Template(
        title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
        description: "VOD - HLS (short)",
        type: .url(.init(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!)
    )
    static let onDemandVideoMP4 = Template(
        title: "The dig",
        description: "VOD - MP4",
        // swiftlint:disable:next line_length
        type: .url(.init(string: "https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")!)
    )
    static let liveVideoHLS = Template(
        title: "Couleur 3 en vidéo (live)",
        description: "Video livestream - HLS",
        type: .url(.init(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!)
    )
    static let dvrVideoHLS = Template(
        title: "Couleur 3 en vidéo (DVR)",
        description: "Video livestream with DVR - HLS",
        type: .url(.init(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")!)
    )
    static let liveTimestampVideoHLS = Template(
        title: "Tageschau",
        description: "Video livestream with DVR and timestamps - HLS",
        type: .url(.init(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!)
    )
    static let onDemandAudioMP3 = Template(
        title: "On en parle",
        description: "AOD - MP3",
        type: .url(.init(string: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")!)
    )
    static let liveAudioMP3 = Template(
        title: "Couleur 3 (live)",
        description: "Audio livestream - MP3",
        type: .url(.init(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!)
    )
    static let dvrAudioHLS = Template(
        title: "Couleur 3 (DVR)",
        description: "Audio livestream - HLS",
        type: .url(.init(string: "https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")!)
    )
    static let appleBasic_4_3_HLS = Template(
        title: "Apple Basic 4:3",
        description: "4x3 aspect ratio, H.264 @ 30Hz",
        type: .url(.init(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!)
    )
    static let appleBasic_16_9_TS_HLS = Template(
        title: "Apple Basic 16:9",
        description: "16x9 aspect ratio, H.264 @ 30Hz",
        type: .url(.init(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
    )
    static let appleAdvanced_16_9_TS_HLS = Template(
        title: "Apple Advanced 16:9 (TS)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
        type: .url(.init(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )
    static let appleAdvanced_16_9_fMP4_HLS = Template(
        title: "Apple Advanced 16:9 (fMP4)",
        description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
        type: .url(.init(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!)
    )
    static let appleAdvanced_16_9_HEVC_h264_HLS = Template(
        title: "Apple Advanced 16:9 (HEVC/H.264)",
        description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
        type: .url(.init(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!)
    )
    static let uhdVideoHLS = Template(
        title: "Brain Farm Skate Phantom Flex",
        description: "4K video",
        type: .url(.init(string: "http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8")!)
    )
    static let onDemandVideoLocalHLS = Template(
        title: "Nyan cat",
        description: "Stream served locally",
        type: .url(.init(string: "http://localhost:8123/on_demand/master.m3u8")!)
    )
    static let unknown = Template(
        title: "Unknown URL",
        type: .url(.init(string: "http://localhost:8123/unavailable/master.m3u8")!)
    )
    static let bitmovinOnDemandMultipleTracks = Template(
        title: "Multiple subtitles and audio tracks",
        type: .url(.init(string: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    )
    static let bitmovinOnDemand_4K_HEVC = Template(
        title: "4K, HEVC",
        type: .url(.init(string: "https://cdn.bitmovin.com/content/encoding_test_dash_hls/4k/hls/4k_profile/master.m3u8")!)
    )
    static let bitmovinOnDemandSingleAudio = Template(
        title: "VoD, single audio track",
        type: .url(.init(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!)
    )
    static let bitmovinOnDemandAES128 = Template(
        title: "AES-128",
        type: .url(.init(string: "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8")!)
    )
    static let bitmovinOnDemandProgressive = Template(
        title: "AVC Progressive",
        type: .url(.init(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/MI201109210084_mpeg-4_hd_high_1080p25_10mbits.mp4")!)
    )
    static let unifiedStreamingOnDemand_fMP4 = Template(
        title: "Fragmented MP4",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandMP4 = Template(
        title: "MP4",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8")!)
    )
    static let unifiedStreamingOnDemandCPIX = Template(
        title: "CPIX",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multikey-cenc.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandAES128 = Template(
        title: "AES-128",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-aes.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandSampleAES = Template(
        title: "SAMPLE-AES",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-sample-aes.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandTransDRM = Template(
        title: "TransDRM",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-pr-transdrm-aes128.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandKeyRotation = Template(
        title: "Key Rotation",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/keyrotation/stable/keyrotation/keyrotation.isml/.m3u8")!)
    )
    static let unifiedStreamingOnDemandWebVTT = Template(
        title: "WebVTT",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multiple-subtitles.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandSingleWebVTT = Template(
        title: "Single fragment WebVTT",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-single-fragment-wvtt.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandSingleTTML = Template(
        title: "Single fragment TTML",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-single-fragment-ttml.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandFragmentedWebVTT = Template(
        title: "Fragmented WebVTT",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-wvtt.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandFragmentedTTML = Template(
        title: "Fragmented TTML",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-ttml.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandMultipleSubtitles = Template(
        title: "Multiple subtitles, RFC 5646 language tags",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-rfc5646.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandAccessibilitySubtitles = Template(
        title: "Accessibility subtitles",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-hoh-subs.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandAlternateAudio = Template(
        title: "Alternate audio language",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandAudioDescription = Template(
        title: "Audio description",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-desc-aud.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemandAudioOnly = Template(
        title: "Audio only",
        // swiftlint:disable:next line_length
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-multi-lang.ism/.m3u8?filter=(type!=%22video%22)")!)
    )
    static let unifiedStreamingOnDemandTrickplay = Template(
        title: "Trickplay",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/no-handler-origin/tears-of-steel/tears-of-steel-trickplay.m3u8")!)
    )
    static let unifiedStreamingOnDemandLimitedBandwidth = Template(
        title: "Limiting bandwidth use",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?max_bitrate=800000")!)
    )
    static let unifiedStreamingOnDemandDynamicTrackSelection = Template(
        title: "Dynamic Track Selection",
        // swiftlint:disable:next line_length
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?filter=%28type%3D%3D%22audio%22%26%26systemBitrate%3C100000%29%7C%7C%28type%3D%3D%22video%22%26%26systemBitrate%3C1024000%29")!)
    )
    static let unifiedStreamingSubclipsCutOffEnd = Template(
        title: "Cut-off end",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?vend=00:01:00")!)
    )
    static let unifiedStreamingSubclipsCreation = Template(
        title: "Subclip creation",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8")!)
    )
    static let unifiedStreamingSubclipsShiftForward = Template(
        title: "Shift forward",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?vbegin=00:06:00")!)
    )
    static let unifiedStreamingSubclipsRange = Template(
        title: "Range",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?t=00:06:00-00:07:30")!)
    )
    static let unifiedStreamingPureLive = Template(
        title: "Pure live",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8")!)
    )
    static let unifiedStreamingTimeshift = Template(
        title: "Timeshift (5 minutes)",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?time_shift=300")!)
    )
    static let unifiedStreamingLiveAudio = Template(
        title: "Live audio",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/live/stable/live.isml/.m3u8?filter=(type!=%22video%22)")!)
    )
    static let unifiedStreamingPureLiveScte35 = Template(
        title: "Pure live (scte35)",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/live/stable/scte35.isml/.m3u8")!)
    )
    static let unifiedStreamingOnDemand_fMP4_Clear = Template(
        title: "fMP4, clear",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-fmp4.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemand_fMP4_PlayReady = Template(
        title: "fMP4, PlayReady",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-hls-playready.ism/.m3u8")!)
    )
    static let unifiedStreamingOnDemand_fMP4_HEVC_4K = Template(
        title: "fMP4, HEVC 4K",
        type: .url(.init(string: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel-hevc.ism/.m3u8")!)
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
        type: .unbufferedUrl(.init(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!)
    )
    static let liveAudio = Template(
        title: "Couleur 3 en direct",
        description: "Audio livestream (unbuffered)",
        type: .unbufferedUrl(.init(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!)
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
        case .urn:
            return nil
        }
    }
}
