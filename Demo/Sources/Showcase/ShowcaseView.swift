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
            Cell(title: "Simple") {
                SimplePlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            }
            Cell(title: "Blurred") {
                BlurredView(media: Media(from: URLTemplate.dvrVideoHLS))
            }
            Cell(title: "Stories") {
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
            Cell(title: "Twins") {
                TwinsView(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            }
            Cell(title: "Multi") {
                MultiView(
                    media1: Media(from: URNTemplate.onDemandHorizontalVideo),
                    media2: Media(from: URNTemplate.onDemandVerticalVideo)
                )
            }
            Cell(title: "Link") {
                LinkView(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
            }
            Cell(title: "Wrapped") {
                WrappedView(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
            }
        }
    }

    @ViewBuilder
    private func trackingSection() -> some View {
        Section("Tracking") {
            Cell(title: "Video URL") {
                TrackingView(media: Media(from: URLTemplate.onDemandVideoMP4))
            }
            Cell(title: "Video URN") {
                TrackingView(media: Media(from: URNTemplate.onDemandVerticalVideo))
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
