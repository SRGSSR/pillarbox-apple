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

    var body: some View {
        CustomList {
            content()
        }
#if os(iOS)
        .navigationTitle("Showcase")
#else
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }

    @ViewBuilder
    private func content() -> some View {
        Group {
            layoutsSection()
            playlistsSection()
            embeddingsSection()
            systemPlayerSection()
            inlineSystemPlayerSection()
            customPictureInPictureSection()
            systemPictureInPictureSection()
            vanillaPlayerSection()
            trackingSection()
            webViewSection()
        }
        .tracked(name: "showcase")
    }

    @ViewBuilder
    private func cell(title: String, subtitle: String? = nil, destination: RouterDestination) -> some View {
        Cell(title: title, subtitle: subtitle) {
            router.presented = destination
        }
    }

    @ViewBuilder
    private func layoutsSection() -> some View {
        CustomSection("Layouts") {
            cell(
                title: "Simple",
                subtitle: "A basic video playback experience",
                destination: .simplePlayer(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            )
            .sourceCode(of: SimplePlayerView.self)

            cell(
                title: "Blurred",
                subtitle: "A video displayed onto a blurred clone of itself",
                destination: .blurred(media: Media(from: URLTemplate.dvrVideoHLS))
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

    @ViewBuilder
    private func playlistsSection() -> some View {
        // swiftlint:disable:next closure_body_length
        CustomSection("Playlists") {
            cell(
                title: "Video URLs",
                destination: .playlist(templates: URLTemplates.videos)
            )
            cell(
                title: "Video URNs",
                destination: .playlist(templates: URNTemplates.videos)
            )
            cell(
                title: "Long video URNs",
                destination: .playlist(templates: URNTemplates.longVideos)
            )
            cell(
                title: "Videos with media selections",
                destination: .playlist(templates: URNTemplates.videosWithMediaSelections)
            )
            cell(
                title: "Audios",
                destination: .playlist(templates: URNTemplates.audios)
            )
            cell(
                title: "Videos (one failed item)",
                destination: .playlist(templates: URNTemplates.videosWithOneError)
            )
            cell(
                title: "Videos (all failing)",
                destination: .playlist(templates: URNTemplates.videosWithErrors)
            )
            cell(
                title: "Empty",
                destination: .playlist(templates: [])
            )
        }
        .sourceCode(of: PlaylistView.self)
    }

    @ViewBuilder
    private func embeddingsSection() -> some View {
        // swiftlint:disable:next closure_body_length
        CustomSection("Embeddings") {
            cell(
                title: "Twins",
                subtitle: "A video displayed twice",
                destination: .twins(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            )
            .sourceCode(of: TwinsView.self)

            cell(
                title: "Multi-instance",
                subtitle: "Two videos played at the same time",
                destination: .multi(
                    media1: Media(from: URNTemplate.onDemandHorizontalVideo),
                    media2: Media(from: URNTemplate.onDemandVideo)
                )
            )
            .sourceCode(of: MultiView.self)

            cell(
                title: "Multi-instance with mixed content",
                subtitle: "Two videos played at the same time",
                destination: .multi(
                    media1: Media(from: URNTemplate.onDemandHorizontalVideo),
                    media2: Media(from: URNTemplate.gothard_360)
                )
            )
            .sourceCode(of: MultiView.self)

            cell(
                title: "Link",
                subtitle: "A player which can be linked to a view",
                destination: .link(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            )
            .sourceCode(of: LinkView.self)

            cell(
                title: "Wrapped",
                subtitle: "A view whose player can be removed",
                destination: .wrapped(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            )
            .sourceCode(of: WrappedView.self)

            cell(
                title: "Transition",
                subtitle: "A transition between two layouts sharing the same player",
                destination: .transition(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            )
            .sourceCode(of: TransitionView.self)
        }
    }

    @ViewBuilder
    private func systemPlayerSection() -> some View {
        CustomSection("System player (using Pillarbox)") {
            cell(
                title: "Apple Basic 16:9",
                destination: .systemPlayer(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            )
            cell(
                title: "Apple Advanced 16:9",
                destination: .systemPlayer(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            )
            cell(
                title: "Trickplay",
                destination: .systemPlayer(media: Media(from: URLTemplate.unifiedStreamingOnDemandTrickplay))
            )
            cell(
                title: "VOD - MP4",
                destination: .systemPlayer(media: Media(from: URLTemplate.onDemandVideoMP4))
            )
            cell(
                title: "Video URN - On-demand",
                destination: .systemPlayer(media: Media(from: URNTemplate.onDemandVideo))
            )
            cell(
                title: "Video URN - Livestream with DRM",
                destination: .systemPlayer(media: Media(from: URNTemplate.dvrVideo))
            )
            cell(
                title: "Unknown",
                destination: .systemPlayer(media: Media(from: URNTemplate.unknown))
            )
        }
        .sourceCode(of: SystemPlayerView.self)
    }

    @ViewBuilder
    private func inlineSystemPlayerSection() -> some View {
        CustomSection("Inline system player (using Pillarbox)") {
            cell(
                title: "Couleur 3 (DVR)",
                destination: .inlineSystemPlayer(media: Media(from: URLTemplate.dvrVideoHLS))
            )
            .sourceCode(of: InlineSystemPlayerView.self)
        }
    }

    @ViewBuilder
    private func customPictureInPictureSection() -> some View {
        // swiftlint:disable:next closure_body_length
        CustomSection("Custom Player and Picture in Picture (PiP) support") {
            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "With PiP support",
                destination: .player(media: Media(from: URLTemplate.dvrVideoHLS))
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "With PiP support",
                destination: .player(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Gothard 360°",
                subtitle: "With PiP support (but unavailable)",
                destination: .player(media: Media(from: URNTemplate.gothard_360))
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "Without PiP support",
                destination: .player(
                    media: Media(from: URLTemplate.dvrVideoHLS),
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "Without PiP support",
                destination: .player(
                    media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS),
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: PlayerView.self)

            cell(
                title: "Gothard 360°",
                subtitle: "Without PiP support",
                destination: .player(
                    media: Media(from: URNTemplate.gothard_360),
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: PlayerView.self)
        }
    }

    @ViewBuilder
    private func systemPictureInPictureSection() -> some View {
        CustomSection("System Player and Picture in Picture (PiP) support") {
            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "With PiP support",
                destination: .systemPlayer(media: Media(from: URLTemplate.dvrVideoHLS))
            )
            .sourceCode(of: SystemPlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "With PiP support",
                destination: .systemPlayer(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            )
            .sourceCode(of: SystemPlayerView.self)

            cell(
                title: "Couleur 3 (DVR)",
                subtitle: "Without PiP support",
                destination: .systemPlayer(
                    media: Media(from: URLTemplate.dvrVideoHLS),
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: SystemPlayerView.self)

            cell(
                title: "Apple Advanced 16:9 (fMP4)",
                subtitle: "Without PiP support",
                destination: .systemPlayer(
                    media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS),
                    supportsPictureInPicture: false
                )
            )
            .sourceCode(of: SystemPlayerView.self)
        }
    }

    @ViewBuilder
    private func vanillaPlayerSection() -> some View {
        CustomSection("System player (using AVPlayer)") {
            cell(
                title: "Apple Basic 16:9",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.appleBasic_16_9_TS_HLS)!)
            )
            cell(
                title: "Apple Advanced 16:9",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS)!)
            )
            cell(
                title: "Trickplay",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.unifiedStreamingOnDemandTrickplay)!)
            )
            cell(
                title: "VOD - MP4",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.onDemandVideoMP4)!)
            )
            cell(
                title: "Unknown",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.unknown)!)
            )
        }
        .sourceCode(of: VanillaPlayerView.self)
    }

    @ViewBuilder
    private func trackingSection() -> some View {
        CustomSection("Opt-in features") {
            cell(
                title: "Video URL",
                destination: .optInPlayer(media: Media(from: URLTemplate.onDemandVideoMP4))
            )
            cell(
                title: "Video URN",
                destination: .optInPlayer(media: Media(from: URNTemplate.onDemandVerticalVideo))
            )
        }
        .sourceCode(of: OptInView.self)
    }
    @ViewBuilder
    private func webViewSection() -> some View {
        CustomSection("Web") {
            cell(title: "Pillarbox App", destination: .webView)
        }
        .sourceCode(of: WebView.self)
    }
}

#Preview {
    NavigationStack {
        ShowcaseView()
    }
    .environmentObject(Router())
}
