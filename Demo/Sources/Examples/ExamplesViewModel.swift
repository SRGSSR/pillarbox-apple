//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderCombine

final class ExamplesViewModel: ObservableObject {
    private enum TriggerId {
        case reload
    }

    let urlMedias = [
        URLMedia.onDemandVideoHLS,
        URLMedia.shortOnDemandVideoHLS,
        URLMedia.onDemandVideoMP4,
        URLMedia.liveVideoHLS,
        URLMedia.dvrVideoHLS,
        URLMedia.liveTimestampVideoHLS,
        URLMedia.onDemandAudioMP3,
        URLMedia.liveAudioMP3
    ]

    let urnMedias = [
        URNMedia.liveVideo,
        URNMedia.dvrVideo,
        URNMedia.dvrAudio
    ]

    let appleMedias = [
        URLMedia.appleBasic_4_3_HLS,
        URLMedia.appleBasic_16_9_TS_HLS,
        URLMedia.appleAdvanced_16_9_TS_HLS,
        URLMedia.appleAdvanced_16_9_fMP4_HLS,
        URLMedia.appleAdvanced_16_9_HEVC_h264_HLS,
        URLMedia.appleWWDCKeynote2023,
        URLMedia.appleDolbyAtmos,
        URLMedia.appleTvMorningShowSeason1Trailer,
        URLMedia.appleTvMorningShowSeason2Trailer
    ]

    let thirdPartyMedias = [
        URLMedia.uhdVideoHLS
    ]

    let bitmovinMedias = [
        URLMedia.bitmovinOnDemandMultipleTracks,
        URLMedia.bitmovinOnDemand_4K_HEVC,
        URLMedia.bitmovinOnDemandSingleAudio,
        URLMedia.bitmovinOnDemandAES128,
        URLMedia.bitmovinOnDemandProgressive
    ]

    let unifiedStreamingMedias = [
        URLMedia.unifiedStreamingOnDemand_fMP4,
        URLMedia.unifiedStreamingOnDemandKeyRotation,
        URLMedia.unifiedStreamingOnDemandAlternateAudio,
        URLMedia.unifiedStreamingOnDemandAudioOnly,
        URLMedia.unifiedStreamingOnDemandTrickplay,
        URLMedia.unifiedStreamingOnDemandLimitedBandwidth,
        URLMedia.unifiedStreamingOnDemandDynamicTrackSelection,
        URLMedia.unifiedStreamingPureLive,
        URLMedia.unifiedStreamingTimeshift,
        URLMedia.unifiedStreamingLiveAudio,
        URLMedia.unifiedStreamingPureLiveScte35,
        URLMedia.unifiedStreamingOnDemand_fMP4_Clear,
        URLMedia.unifiedStreamingOnDemand_fMP4_HEVC_4K
    ]

    let bbcTestCardMedias = [
        URLMedia.bbcTestCard_Audio_Video_AVC,
        URLMedia.bbcTestCard_Audio_Video_AVC_TVs,
        URLMedia.bbcTestCard_Audio_Video_AVC_Mobile,
        URLMedia.bbcTestCard_Audio_Video_HEVC_TVs,
        URLMedia.bbcTestCard_Audio_HE_LC_AAC_en,
        URLMedia.bbcTestCard_Audio_HE_AAC_en,
        URLMedia.bbcTestCard_Audio_AAC_LC_en,
        URLMedia.bbcTestCard_Audio_AAC_LC_de,
        URLMedia.bbcTestCard_Audio_AAC_LC_fr,
        URLMedia.bbcTestCard_Audio_HE_LC_AAC_all,
        URLMedia.bbcTestCard_Audio_AAC_LC_surround_en,
        URLMedia.bbcTestCard_Audio_AAC_LC_surround_de,
        URLMedia.bbcTestCard_Audio_AAC_LC_surround_fr,
        URLMedia.bbcTestCard_Audio_FLAC_en,
        URLMedia.bbcTestCard_Restricted_Stereo_TVs,
        URLMedia.bbcTestCard_Restricted_HEVC_Stereo_TVs,
        URLMedia.bbcTestCard_Restricted_NoSubtitles_TVs,
        URLMedia.bbcTestCard_Single_192x108p25_AAC_LC,
        URLMedia.bbcTestCard_Single_256x144p25_AAC_LC,
        URLMedia.bbcTestCard_Single_384x216p25_AAC_LC,
        URLMedia.bbcTestCard_Single_512x288p25_AAC_LC,
        URLMedia.bbcTestCard_Single_704x396p25_AAC_LC,
        URLMedia.bbcTestCard_Single_704x396p50_AAC_LC,
        URLMedia.bbcTestCard_Single_896x504p25_AAC_LC,
        URLMedia.bbcTestCard_Single_960x540p50_AAC_LC,
        URLMedia.bbcTestCard_Single_1280x720p50_AAC_LC,
        URLMedia.bbcTestCard_Single_1920x1080p50_AAC_LC,
        URLMedia.bbcTestCard_Single_1280x720p50_HE_AAC,
        URLMedia.bbcTestCard_Single_1280x720p50_HEVC_AAC_LC,
        URLMedia.bbcTestCard_Single_1920x1080p50_HEVC_AAC_LC,
        URLMedia.bbcTestCard_NoTLS_HTTP_TVs,
        URLMedia.bbcTestCard_NoTLS_Relative_TVs,
        URLMedia.bbcTestCard_NoTLS_Relative_Mobile
    ]

    let muxMedias = [
        URLMedia.mux_LowLatency
    ]

    let aspectRatioMedias = [
        URNMedia.onDemandHorizontalVideo,
        URNMedia.onDemandSquareVideo,
        URNMedia.onDemandVerticalVideo
    ]

    let threeSixtyMedias = [
        URNMedia.gothard_360,
        URLMedia.bitmovin_360,
        URLMedia.apple_360
    ]

    let unbufferedMedias = [
        UnbufferedURLMedia.liveVideo,
        UnbufferedURLMedia.liveAudio
    ]

    let cornerCaseMedias = [
        URNMedia.unknown,
        URLMedia.unknown,
        URLMedia.unauthorized,
        URLMedia.unavailableMp3
    ]

    let timeRangesMedias = [
        URLMedia.timeRangesVideo,
        URLMedia.blockedTimeRangesVideo,
        URNMedia.blockedTimeRangesVideo
    ]

    @Published private(set) var protectedMedias = [Media]()
    private let trigger = Trigger()

    init() {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
            Self.protectedStreamPublisher()
        }
        .receiveOnMainThread()
        .assign(to: &$protectedMedias)
    }

    private static func protectedStreamPublisher() -> AnyPublisher<[Media], Never> {
        Publishers.CombineLatest(
            drmProtectedStreamPublisher(),
            tokenProtectedStreamPublisher()
        )
        .map { $0 + $1 }
        .eraseToAnyPublisher()
    }

    private static func drmProtectedStreamPublisher() -> AnyPublisher<[Media], Never> {
        SRGDataProvider.current!.latestMediasForShow(withUrn: "urn:rts:show:tv:532539", pageSize: 2)
            .replaceError(with: [])
            .map { medias in
                medias.map { media in
                    Media(
                        title: title(of: media),
                        subtitle: "DRM-protected video",
                        imageUrl: SRGDataProvider.current!.url(for: media.show?.image, size: .large),
                        type: .urn(media.urn)
                    )
                }
            }
            .prepend([])
            .eraseToAnyPublisher()
    }

    private static func tokenProtectedStreamPublisher() -> AnyPublisher<[Media], Never> {
        SRGDataProvider.current!.liveCenterVideos(for: .RTS, pageSize: 2)
            .replaceError(with: [])
            .map { medias in
                medias.map { media in
                    Media(
                        title: media.title,
                        subtitle: "Token-protected video",
                        imageUrl: SRGDataProvider.current!.url(for: media.image, size: .large),
                        type: .urn(media.urn)
                    )
                }
            }
            .prepend([])
            .eraseToAnyPublisher()
    }

    private static func title(of media: SRGMedia) -> String {
        if let title = media.show?.title {
            return "\(title) (\(media.title))"
        }
        else {
            return media.title
        }
    }

    func refresh() async {
        Task {
            try? await Task.sleep(for: .seconds(1))
            trigger.activate(for: TriggerId.reload)
        }
    }
}
