//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import SRGDataProviderCombine

final class ExamplesViewModel: ObservableObject {
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
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS
    ])

    let cornerCaseMedias = Template.medias(from: [
        URNTemplate.expired,
        URNTemplate.unknown
    ])

    @Published private(set) var protectedMedias = [Media]()

    init() {
        Self.protectedStreamPublisher()
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
}
