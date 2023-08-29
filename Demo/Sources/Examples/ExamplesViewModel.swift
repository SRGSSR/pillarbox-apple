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

    let aspectRatioMedias = Template.medias(from: [
        URNTemplate.onDemandHorizontalVideo,
        URNTemplate.onDemandSquareVideo,
        URNTemplate.onDemandVerticalVideo
    ])

    let unbufferedMedias = Template.medias(from: [
        UnbufferedURLTemplate.liveVideo,
        UnbufferedURLTemplate.liveAudio
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

    let unifiedStreamingSourceMedias = Template.medias(from: [
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

    let cornerCaseMedias = Template.medias(from: [
        URNTemplate.expired,
        URNTemplate.unknown
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
                        description: "DRM-protected video",
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
                        description: "Token-protected video",
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
