//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import SwiftUI

// Behavior: h-exp, v-exp
struct ShowcaseView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        List {
            layoutsSection()
            playlistsSection()
            embeddingsSection()
            systemPlayerSection()
            vanillaPlayerSection()
            trackingSection()
        }
        .navigationTitle("Showcase")
        .tracked(name: "showcase")
    }

    @ViewBuilder
    private func cell(title: String, subtitle: String? = nil, destination: RouterDestination) -> some View {
        Cell(title: title, subtitle: subtitle) {
            router.present(destination)
        }
    }

    @ViewBuilder
    private func layoutsSection() -> some View {
        Section("Layouts") {
            cell(
                title: "Simple",
                subtitle: "A basic video playback experience",
                destination: .simplePlayer(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            )
            cell(
                title: "Blurred",
                subtitle: "A video displayed onto a blurred clone of itself",
                destination: .blurred(media: Media(from: URLTemplate.dvrVideoHLS))
            )
            cell(
                title: "Stories",
                subtitle: "An Instagram-inspired user experience",
                destination: .stories
            )
        }
    }

    @ViewBuilder
    private func playlistsSection() -> some View {
        Section("Playlists") {
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
    }

    @ViewBuilder
    private func embeddingsSection() -> some View {
        Section("Embeddings") {
            cell(
                title: "Twins",
                subtitle: "A video displayed twice",
                destination: .twins(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            )
            cell(
                title: "Multi-instance",
                subtitle: "Two videos played at the same time",
                destination: .multi(
                    media1: Media(from: URNTemplate.onDemandHorizontalVideo),
                    media2: Media(from: URNTemplate.onDemandVideo)
                )
            )
            cell(
                title: "Link",
                subtitle: "A player which can be linked to a view",
                destination: .link(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            )
            cell(
                title: "Wrapped",
                subtitle: "A view whose player can be removed",
                destination: .wrapped(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            )
        }
    }

    @ViewBuilder
    private func systemPlayerSection() -> some View {
        Section("System player (using Pillarbox)") {
            cell(
                title: "Video URL",
                destination: .systemPlayer(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            )
            cell(
                title: "Video URN",
                destination: .systemPlayer(media: Media(from: URNTemplate.dvrVideo))
            )
            cell(
                title: "Unknown",
                destination: .systemPlayer(media: Media(from: URNTemplate.unknown))
            )
        }
    }

    @ViewBuilder
    private func vanillaPlayerSection() -> some View {
        Section("System player (using AVPlayer)") {
            cell(
                title: "Video URL",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.appleAdvanced_16_9_TS_HLS)!)
            )
            cell(
                title: "Unknown",
                destination: .vanillaPlayer(item: Template.playerItem(from: URLTemplate.unknown)!)
            )
        }
    }

    @ViewBuilder
    private func trackingSection() -> some View {
        Section("Opt-in features") {
            cell(
                title: "Video URL",
                destination: .optInPlayer(media: Media(from: URLTemplate.onDemandVideoMP4))
            )
            cell(
                title: "Video URN",
                destination: .optInPlayer(media: Media(from: URNTemplate.onDemandVerticalVideo))
            )
        }
    }
}

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        RoutedNavigationStack {
            ShowcaseView()
        }
    }
}
