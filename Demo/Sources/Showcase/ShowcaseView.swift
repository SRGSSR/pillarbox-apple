//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-exp, v-exp
struct ShowcaseView: View {
    // swiftlint:disable:previous type_body_length
    @EnvironmentObject private var router: Router
    @StateObject private var settingBundle = SettingsBundle()

    var body: some View {
        CustomList {
            content()
        }
        .tracked(name: "showcase")
#if os(iOS)
        .navigationTitle("Showcase")
#else
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }

    @ViewBuilder
    private func content() -> some View {
        layoutsSection()
        playlistsSection()
        embeddingsSection()
        pictureInPictureCornerCases()
        systemPlayerSection()
        miscellaneousPlayerFeaturesSection()
        customPictureInPictureSection()
        systemPictureInPictureSection()
        vanillaPlayerSection()
        trackingSection()
#if os(iOS)
        webViewSection()
#endif
    }

    private func cell(title: String, subtitle: String? = nil, destination: RouterDestination) -> some View {
        Cell(title: title, subtitle: subtitle) {
            router.presented = destination
        }
    }

    private func layoutsSection() -> some View {
        CustomSection("Layouts") {
            cell(
                title: "Simple",
                subtitle: "A basic video playback experience",
                destination: .simplePlayer(media: URLMedia.appleAdvanced_16_9_HEVC_h264_HLS)
            )
            .sourceCode(of: SimplePlayerView.self)

            cell(
                title: "Blurred",
                subtitle: "A video displayed onto a blurred clone of itself",
                destination: .blurred(media: URLMedia.dvrVideoHLS)
            )
            .sourceCode(of: BlurredView.self)

            cell(
                title: "Stories",
                subtitle: "An Instagram-inspired user experience",
                destination: .stories
            )
            .sourceCode(of: StoriesView.self)
        }
    }

    private func playlistsSection() -> some View {
        // swiftlint:disable:previous function_body_length
        // swiftlint:disable:next closure_body_length
        CustomSection("Playlists") {
            cell(
                title: "Video URLs",
                destination: .playlist(medias: MediaList.videoUrls)
            )
            cell(
                title: "Video URNs",
                destination: .playlist(medias: MediaList.videoUrns)
            )
            cell(
                title: "Long video URNs",
                destination: .playlist(medias: MediaList.longVideoUrns)
            )
            cell(
                title: "Videos with media selections",
                destination: .playlist(medias: MediaList.videosWithMediaSelections)
            )
            cell(
                title: "Audios",
                destination: .playlist(medias: MediaList.audios)
            )
            cell(
                title: "Videos (URLs, one failing)",
                destination: .playlist(medias: MediaList.videosWithOneFailingUrl)
            )
            cell(
                title: "Videos (URLs, one failing MP3)",
                destination: .playlist(medias: MediaList.videosWithOneFailingMp3Url)
            )
            cell(
                title: "Videos (URNs, one failing)",
                destination: .playlist(medias: MediaList.videosWithOneFailingUrn)
            )
            cell(
                title: "Videos (URLs, all failing)",
                destination: .playlist(medias: MediaList.videosWithOnlyFailingUrls)
            )
            cell(
                title: "Videos (URNs, all failing)",
                destination: .playlist(medias: MediaList.videosWithOnlyFailingUrns)
            )
            cell(
                title: "Videos (URLs and URNs, all failing)",
                destination: .playlist(medias: MediaList.videosWithFailingUrlsAndUrns)
            )
            cell(
                title: "Empty",
                destination: .playlist(medias: [])
            )
        }
        .sourceCode(of: PlaylistView.self)
    }

    private func embeddingsSection() -> some View {
        // swiftlint:disable:next closure_body_length
        CustomSection("Embeddings") {
            cell(
                title: "Twins",
                subtitle: "A video displayed twice",
                destination: .twins(media: URLMedia.appleBasic_16_9_TS_HLS)
            )
            .sourceCode(of: TwinsView.self)

            cell(
                title: "Multi-instance",
                subtitle: "Two videos played at the same time",
                destination: .multi(
                    media1: URNMedia.onDemandHorizontalVideo,
                    media2: URNMedia.onDemandVideo
                )
            )
            .sourceCode(of: MultiView.self)

            cell(
                title: "Multi-instance with mixed content",
                subtitle: "Two videos played at the same time",
                destination: .multi(
                    media1: URNMedia.onDemandHorizontalVideo,
                    media2: URNMedia.gothard_360
                )
            )
            .sourceCode(of: MultiView.self)

            cell(
                title: "Link",
                subtitle: "A player which can be linked to a view",
                destination: .link(media: URLMedia.appleAdvanced_16_9_fMP4_HLS)
            )
            .sourceCode(of: LinkView.self)

            cell(
                title: "Wrapped",
                subtitle: "A view whose player can be removed",
                destination: .wrapped(media: URLMedia.appleBasic_16_9_TS_HLS)
            )
            .sourceCode(of: WrappedView.self)

            cell(
                title: "Transition",
                subtitle: "A transition between two layouts sharing the same player",
                destination: .transition(media: URLMedia.appleBasic_16_9_TS_HLS)
            )
            .sourceCode(of: TransitionView.self)
        }
    }

    private func pictureInPictureCornerCases() -> some View {
        CustomSection("Picture in Picture Corner Cases") {
            cell(
                title: "Twins",
                subtitle: "A video displayed twice",
                destination: .twinsPiP(media: URLMedia.appleBasic_16_9_TS_HLS)
            )
            .sourceCode(of: TwinsPiPView.self)

            cell(
                title: "Multi-instance",
                subtitle: "Two videos played at the same time",
                destination: .multiPiP(
                    media1: URNMedia.onDemandHorizontalVideo,
                    media2: URNMedia.onDemandVideo
                )
            )
            .sourceCode(of: MultiPiPView.self)

            cell(
                title: "System multi-instance",
                subtitle: "Two videos played at the same time",
                destination: .multiSystemPiP(
                    media1: URNMedia.onDemandHorizontalVideo,
                    media2: URNMedia.onDemandVideo
                )
            )
            .sourceCode(of: MultiPiPView.self)

            cell(
                title: "Transition",
                subtitle: "A transition between two layouts sharing the same player",
                destination: .transitionPiP(media: URLMedia.appleBasic_16_9_TS_HLS)
            )
            .sourceCode(of: TransitionPiPView.self)
        }
    }

    private func systemPlayerSection() -> some View {
        CustomSection("System player (using Pillarbox)") {
            cell(
                title: "Apple Basic 16:9",
                destination: .systemPlayer(media: URLMedia.appleBasic_16_9_TS_HLS)
            )
            cell(
                title: "Apple Advanced 16:9",
                destination: .systemPlayer(media: URLMedia.appleAdvanced_16_9_fMP4_HLS)
            )
            cell(
                title: "Trickplay",
                destination: .systemPlayer(media: URLMedia.unifiedStreamingOnDemandTrickplay)
            )
            cell(
                title: "VOD - MP4",
                destination: .systemPlayer(media: URLMedia.onDemandVideoMP4)
            )
            cell(
                title: "Video URN - On-demand",
                destination: .systemPlayer(media: URNMedia.onDemandVideo)
            )
            cell(
                title: "Video URN - Livestream with DRM",
                destination: .systemPlayer(media: URNMedia.dvrVideo)
            )
            cell(
                title: "Unknown",
                destination: .systemPlayer(media: URNMedia.unknown)
            )
        }
        .sourceCode(of: SystemPlayerView.self)
    }

    private func miscellaneousPlayerFeaturesSection() -> some View {
        CustomSection("Miscellaneous player features (using Pillarbox)") {
            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "Inline system playback view",
                destination: .inlineSystemPlayer(media: URLMedia.dvrVideoHLS)
            )
            .sourceCode(of: InlineSystemPlayerView.self)

            cell(
                title: "Apple Basic 16:9",
                subtitle: "Playback start at 10 minutes",
                destination: .player(media: URLMedia.startTimeVideo)
            )
            .sourceCode(of: PlayerView.self)
        }
    }

    private func customPictureInPictureSection() -> some View {
        // swiftlint:disable:next closure_body_length
        CustomSection("Custom Player and Picture in Picture (PiP) support") {
            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "With PiP support",
                destination: .player(media: URLMedia.dvrVideoHLS)
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "With PiP support",
                destination: .player(media: URLMedia.appleAdvanced_16_9_fMP4_HLS)
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Gothard 360°",
                subtitle: "With PiP support (but unavailable)",
                destination: .player(media: URNMedia.gothard_360)
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "Without PiP support",
                destination: .player(
                    media: URLMedia.dvrVideoHLS,
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "Without PiP support",
                destination: .player(
                    media: URLMedia.appleAdvanced_16_9_fMP4_HLS,
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Gothard 360°",
                subtitle: "Without PiP support",
                destination: .player(
                    media: URNMedia.gothard_360,
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: PlayerView.self)
        }
    }

    private func systemPictureInPictureSection() -> some View {
        CustomSection("System Player and Picture in Picture (PiP) support") {
            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "With PiP support",
                destination: .systemPlayer(media: URLMedia.dvrVideoHLS)
            )
            .sourceCode(of: SystemPlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "With PiP support",
                destination: .systemPlayer(media: URLMedia.appleAdvanced_16_9_fMP4_HLS)
            )
            .sourceCode(of: SystemPlayerView.self)

            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "Without PiP support",
                destination: .systemPlayer(
                    media: URLMedia.dvrVideoHLS,
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: SystemPlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "Without PiP support",
                destination: .systemPlayer(
                    media: URLMedia.appleAdvanced_16_9_fMP4_HLS,
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: SystemPlayerView.self)
        }
    }

    private func vanillaPlayerSection() -> some View {
        CustomSection("System player (using AVPlayer)") {
            cell(
                title: "Apple Basic 16:9",
                destination: .vanillaPlayer(item: URLMedia.appleBasic_16_9_TS_HLS.playerItem()!)
            )
            cell(
                title: "Apple Advanced 16:9",
                destination: .vanillaPlayer(item: URLMedia.appleAdvanced_16_9_fMP4_HLS.playerItem()!)
            )
            cell(
                title: "Trickplay",
                destination: .vanillaPlayer(item: URLMedia.unifiedStreamingOnDemandTrickplay.playerItem()!)
            )
            cell(
                title: "VOD - MP4",
                destination: .vanillaPlayer(item: URLMedia.onDemandVideoMP4.playerItem()!)
            )
            cell(
                title: "Unknown",
                destination: .vanillaPlayer(item: URLMedia.unknown.playerItem()!)
            )
        }
        .sourceCode(of: VanillaPlayerView.self)
    }

    private func trackingSection() -> some View {
        CustomSection("Opt-in features") {
            cell(
                title: "Video URL",
                destination: .optInPlayer(media: URLMedia.onDemandVideoMP4)
            )
            cell(
                title: "Video URN",
                destination: .optInPlayer(media: URNMedia.onDemandHorizontalVideo)
            )
        }
        .sourceCode(of: OptInView.self)
    }

#if os(iOS)
    @ViewBuilder
    private func webViewSection() -> some View {
        if settingBundle.showsHiddenFeatures {
            CustomSection("Web") {
                cell(
                    title: "Demo",
                    destination: .webView(url: "https://srgssr.github.io/pillarbox-web-demo/")
                )
            }
            .sourceCode(of: WebView.self)
        }
    }
#endif
}

#Preview {
    NavigationStack {
        ShowcaseView()
    }
    .environmentObject(Router())
}
