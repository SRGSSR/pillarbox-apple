//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-hug, v-hug
private struct Cell<Presented: View>: View {
    let title: String

    @ViewBuilder var presented: () -> Presented
    @State private var isPresented = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $isPresented, content: presented)
    }

    private func action() {
        isPresented.toggle()
    }
}

// Behavior: h-exp, v-exp
struct ShowcaseView: View {
    var body: some View {
        List {
            layoutsSection()
            playlistsSection()
            embeddingsSection()
        }
        .navigationTitle("Showcase")
    }

    @ViewBuilder
    private func layoutsSection() -> some View {
        Section("Layouts") {
            Cell(title: "Simple") {
                SimplePlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
            }
            Cell(title: "Stories") {
                StoriesView()
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
            Cell(title: "Token-protected video URNs") {
                PlaylistView(templates: URNTemplates.tokenProtectedVideos)
            }
            Cell(title: "DRM-protected video URNs") {
                PlaylistView(templates: URNTemplates.drmProtectedVideos)
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
                    media1: Media(from: URLTemplate.appleBasic_16_9_TS_HLS),
                    media2: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS)
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
}

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShowcaseView()
        }
    }
}
