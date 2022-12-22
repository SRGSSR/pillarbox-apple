//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: Cells

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

// MARK: View

// Behavior: h-exp, v-exp
struct ShowcaseView: View {
    var body: some View {
        // swiftlint:disable:next closure_body_length
        List {
            Group {
                Cell(title: "Basic") {
                    BasicPlayerView(media: MediaURL.appleAdvanced_16_9_HEVC_h264_HLS)
                }
                Cell(title: "Unbuffered video livestream") {
                    PlayerView(media: UnbufferedMediaURL.liveVideo)
                }
                Cell(title: "Unbuffered on-demand audio") {
                    PlayerView(media: UnbufferedMediaURL.onDemandAudio)
                }
                Cell(title: "Unbuffered audio livestream") {
                    PlayerView(media: UnbufferedMediaURL.liveAudio)
                }
                Cell(title: "Stories") {
                    StoriesView()
                }
                Cell(title: "Twins") {
                    TwinsView(media: MediaURL.appleBasic_16_9_TS_HLS)
                }
                Cell(title: "Multi") {
                    MultiView(
                        media1: MediaURL.appleBasic_16_9_TS_HLS,
                        media2: MediaURL.appleAdvanced_16_9_HEVC_h264_HLS
                    )
                }
            }
            Group {
                Cell(title: "Link") {
                    LinkView(media: MediaURL.appleAdvanced_16_9_fMP4_HLS)
                }
                Cell(title: "Wrapped") {
                    WrappedView(media: MediaURL.appleBasic_16_9_TS_HLS)
                }
                Cell(title: "Playlist (URLs)") {
                    PlaylistView(medias: MediaURLPlaylist.videos)
                }
                Cell(title: "Playlist (URNs)") {
                    PlaylistView(medias: MediaURNPlaylist.videos)
                }
                Cell(title: "Playlist (URNs, long)") {
                    PlaylistView(medias: MediaURNPlaylist.longVideos)
                }
                Cell(title: "Playlist (URNs, token-protected)") {
                    PlaylistView(medias: MediaURNPlaylist.tokenProtectedVideos)
                }
                Cell(title: "Playlist (URNs, DRM-protected)") {
                    PlaylistView(medias: MediaURNPlaylist.drmProtectedVideos)
                }
                Cell(title: "Audio playlist (URNs)") {
                    PlaylistView(medias: MediaURNPlaylist.audios)
                }
                Cell(title: "Playlist (with errors)") {
                    PlaylistView(medias: MediaURNPlaylist.videosWithErrors)
                }
                Cell(title: "Dynamic Playlist") {
                    DynamicPlaylistView(medias: MediaURLPlaylist.videosWithDescription)
                }
            }
        }
        .navigationTitle("Showcase")
    }
}

// MARK: Preview

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShowcaseView()
        }
    }
}
