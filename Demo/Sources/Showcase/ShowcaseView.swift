//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import SwiftUI

// Behavior: h-exp, v-exp
struct ShowcaseView: View {
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
        .tracked(title: "showcase")
    }

    @ViewBuilder
    private func layoutsSection() -> some View {
        Section("Layouts") {
            Cell(title: "Simple", subtitle: "A basic video playback experience") {
                SimplePlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            }
            Cell(title: "Blurred", subtitle: "A video displayed onto a blurred clone of itself") {
                BlurredView(media: Media(from: URLTemplate.dvrVideoHLS))
            }
            Cell(title: "Stories", subtitle: "An Instagram-inspired user experience") {
                StoriesView()
            }
        }
    }

    @ViewBuilder
    private func systemPlayerSection() -> some View {
        Section("System player (using Pillarbox)") {
            Cell(title: "Video URL") {
                SystemPlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            }
            Cell(title: "Video URN") {
                SystemPlayerView(media: Media(from: URNTemplate.dvrVideo))
            }
            Cell(title: "Unknown") {
                SystemPlayerView(media: Media(from: URNTemplate.unknown))
            }
        }
    }

    @ViewBuilder
    private func vanillaPlayerSection() -> some View {
        Section("System player (using AVPlayer)") {
            Cell(title: "Video URL") {
                VanillaPlayerView(item: Template.playerItem(from: URLTemplate.appleAdvanced_16_9_TS_HLS)!)
            }
            Cell(title: "Unknown") {
                VanillaPlayerView(item: Template.playerItem(from: URLTemplate.unknown)!)
            }
        }
    }

    @ViewBuilder
    private func playlistsSection() -> some View {
        Section("Playlists") {
            Cell(title: "Video URLs") {
                PlaylistView(templates: URLTemplates.videos)
            }
            Cell(title: "Video URNs") {
                PlaylistView(templates: URNTemplates.videos)
            }
            Cell(title: "Long video URNs") {
                PlaylistView(templates: URNTemplates.longVideos)
            }
            Cell(title: "Audios") {
                PlaylistView(templates: URNTemplates.audios)
            }
            Cell(title: "Videos (one failed item)") {
                PlaylistView(templates: URNTemplates.videosWithOneError)
            }
            Cell(title: "Videos (all failing)") {
                PlaylistView(templates: URNTemplates.videosWithErrors)
            }
            Cell(title: "Empty") {
                PlaylistView(templates: [])
            }
        }
    }

    @ViewBuilder
    private func embeddingsSection() -> some View {
        Section("Embeddings") {
            Cell(title: "Twins", subtitle: "A video displayed twice") {
                TwinsView(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            }
            Cell(title: "Multi", subtitle: "Two videos played at the same time") {
                MultiView(
                    media1: Media(from: URNTemplate.onDemandHorizontalVideo),
                    media2: Media(from: URNTemplate.onDemandVideo)
                )
            }
            Cell(title: "Link", subtitle: "A player which can be linked to a view") {
                LinkView(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            }
            Cell(title: "Wrapped", subtitle: "A view whose player can be removed") {
                WrappedView(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            }
        }
    }

    @ViewBuilder
    private func trackingSection() -> some View {
        Section("Opt-in features") {
            Cell(title: "Video URL") {
                OptInView(media: Media(from: URLTemplate.onDemandVideoMP4))
            }
            Cell(title: "Video URN") {
                OptInView(media: Media(from: URNTemplate.onDemandVerticalVideo))
            }
        }
    }
}

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShowcaseView()
        }
    }
}
