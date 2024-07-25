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

    let urlMedias = Template.medias(from: [
        URLTemplate.onDemandVideoHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.onDemandVideoMP4,
        URLTemplate.liveVideoHLS,
        URLTemplate.dvrVideoHLS,
        URLTemplate.liveTimestampVideoHLS,
        URLTemplate.onDemandAudioMP3,
        URLTemplate.liveAudioMP3
    ])

    let urnMedias = Template.medias(from: [
        URNTemplate.liveVideo,
        URNTemplate.dvrVideo,
        URNTemplate.dvrAudio
    ])

    let appleMedias = Template.medias(from: [
        URLTemplate.appleBasic_4_3_HLS,
        URLTemplate.appleBasic_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_fMP4_HLS,
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS,
        URLTemplate.appleWWDCKeynote2023,
        URLTemplate.appleDolbyAtmos,
        URLTemplate.appleTvMorningShowSeason1Trailer,
        URLTemplate.appleTvMorningShowSeason2Trailer
    ])

    let thirdPartyMedias = Template.medias(from: [
        URLTemplate.uhdVideoHLS
    ])

    let bitmovinMedias = Template.medias(from: [
        URLTemplate.bitmovinOnDemandMultipleTracks,
        URLTemplate.bitmovinOnDemand_4K_HEVC,
        URLTemplate.bitmovinOnDemandSingleAudio,
        URLTemplate.bitmovinOnDemandAES128,
        URLTemplate.bitmovinOnDemandProgressive
    ])

    let unifiedStreamingMedias = Template.medias(from: [
        URLTemplate.unifiedStreamingOnDemand_fMP4,
        URLTemplate.unifiedStreamingOnDemandKeyRotation,
        URLTemplate.unifiedStreamingOnDemandAlternateAudio,
        URLTemplate.unifiedStreamingOnDemandAudioOnly,
        URLTemplate.unifiedStreamingOnDemandTrickplay,
        URLTemplate.unifiedStreamingOnDemandLimitedBandwidth,
        URLTemplate.unifiedStreamingOnDemandDynamicTrackSelection,
        URLTemplate.unifiedStreamingPureLive,
        URLTemplate.unifiedStreamingTimeshift,
        URLTemplate.unifiedStreamingLiveAudio,
        URLTemplate.unifiedStreamingPureLiveScte35,
        URLTemplate.unifiedStreamingOnDemand_fMP4_Clear,
        URLTemplate.unifiedStreamingOnDemand_fMP4_HEVC_4K
    ])

    let bbcTestCardMedias = Template.medias(from: [
        URLTemplate.bbcTestCard_Audio_Video_AVC,
        URLTemplate.bbcTestCard_Audio_Video_AVC_TVs,
        URLTemplate.bbcTestCard_Audio_Video_AVC_Mobile,
        URLTemplate.bbcTestCard_Audio_Video_HEVC_TVs,
        URLTemplate.bbcTestCard_Audio_HE_LC_AAC_en,
        URLTemplate.bbcTestCard_Audio_HE_AAC_en,
        URLTemplate.bbcTestCard_Audio_AAC_LC_en,
        URLTemplate.bbcTestCard_Audio_AAC_LC_de,
        URLTemplate.bbcTestCard_Audio_AAC_LC_fr,
        URLTemplate.bbcTestCard_Audio_HE_LC_AAC_all,
        URLTemplate.bbcTestCard_Audio_AAC_LC_surround_en,
        URLTemplate.bbcTestCard_Audio_AAC_LC_surround_de,
        URLTemplate.bbcTestCard_Audio_AAC_LC_surround_fr,
        URLTemplate.bbcTestCard_Audio_FLAC_en,
        URLTemplate.bbcTestCard_Restricted_Stereo_TVs,
        URLTemplate.bbcTestCard_Restricted_HEVC_Stereo_TVs,
        URLTemplate.bbcTestCard_Restricted_NoSubtitles_TVs,
        URLTemplate.bbcTestCard_Single_192x108p25_AAC_LC,
        URLTemplate.bbcTestCard_Single_256x144p25_AAC_LC,
        URLTemplate.bbcTestCard_Single_384x216p25_AAC_LC,
        URLTemplate.bbcTestCard_Single_512x288p25_AAC_LC,
        URLTemplate.bbcTestCard_Single_704x396p25_AAC_LC,
        URLTemplate.bbcTestCard_Single_704x396p50_AAC_LC,
        URLTemplate.bbcTestCard_Single_896x504p25_AAC_LC,
        URLTemplate.bbcTestCard_Single_960x540p50_AAC_LC,
        URLTemplate.bbcTestCard_Single_1280x720p50_AAC_LC,
        URLTemplate.bbcTestCard_Single_1920x1080p50_AAC_LC,
        URLTemplate.bbcTestCard_Single_1280x720p50_HE_AAC,
        URLTemplate.bbcTestCard_Single_1280x720p50_HEVC_AAC_LC,
        URLTemplate.bbcTestCard_Single_1920x1080p50_HEVC_AAC_LC,
        URLTemplate.bbcTestCard_NoTLS_HTTP_TVs,
        URLTemplate.bbcTestCard_NoTLS_Relative_TVs,
        URLTemplate.bbcTestCard_NoTLS_Relative_Mobile
    ])

    let aspectRatioMedias = Template.medias(from: [
        URNTemplate.onDemandHorizontalVideo,
        URNTemplate.onDemandSquareVideo,
        URNTemplate.onDemandVerticalVideo
    ])

    let threeSixtyMedias = Template.medias(from: [
        URNTemplate.gothard_360,
        URLTemplate.bitmovin_360
    ])

    let unbufferedMedias = Template.medias(from: [
        UnbufferedURLTemplate.liveVideo,
        UnbufferedURLTemplate.liveAudio
    ])

    let cornerCaseMedias = Template.medias(from: [
        URNTemplate.unknown,
        URNTemplate.expired,
        URLTemplate.unknown,
        URLTemplate.unauthorized,
        URLTemplate.unavailableMp3
    ])

    let timeRangesMedias = Template.medias(from: [
        URLTemplate.timeRangesVideo,
        URLTemplate.blockedTimeRangesVideo,
        URNTemplate.blockedTimeRangesVideo
    ])

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
                        type: .urn(media.urn),
                        isMonoscopic: media.isMonoscopic
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
                        type: .urn(media.urn),
                        isMonoscopic: media.isMonoscopic
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
