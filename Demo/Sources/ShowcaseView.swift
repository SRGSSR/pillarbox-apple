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
                Cell(title: "Simplest player") {
                    SimplePlayerView(media: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS.media())
                }
                Cell(title: "Unbuffered video livestream") {
                    PlayerView(media: UnbufferedURLTemplate.liveVideo.media())
                }
                Cell(title: "Unbuffered on-demand audio") {
                    PlayerView(media: UnbufferedURLTemplate.onDemandAudio.media())
                }
                Cell(title: "Unbuffered audio livestream") {
                    PlayerView(media: UnbufferedURLTemplate.liveAudio.media())
                }
                Cell(title: "Stories") {
                    StoriesView()
                }
                Cell(title: "Twins") {
                    TwinsView(media: URLTemplate.appleBasic_16_9_TS_HLS.media())
                }
                Cell(title: "Multi") {
                    MultiView(
                        media1: URLTemplate.appleBasic_16_9_TS_HLS.media(),
                        media2: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS.media()
                    )
                }
            }
            Group {
                Cell(title: "Link") {
                    LinkView(media: URLTemplate.appleAdvanced_16_9_fMP4_HLS.media())
                }
                Cell(title: "Wrapped") {
                    WrappedView(media: URLTemplate.appleBasic_16_9_TS_HLS.media())
                }
            }
            Group {
                Cell(title: "Playlist (URLs)") {
                    PlaylistView(templates: URLPlaylist.videos)
                }
                Cell(title: "Playlist (URNs)") {
                    PlaylistView(templates: URNPlaylist.videos)
                }
                Cell(title: "Playlist (URNs, long)") {
                    PlaylistView(templates: URNPlaylist.longVideos)
                }
                Cell(title: "Playlist (URNs, token-protected)") {
                    PlaylistView(templates: URNPlaylist.tokenProtectedVideos)
                }
                Cell(title: "Playlist (URNs, DRM-protected)") {
                    PlaylistView(templates: URNPlaylist.drmProtectedVideos)
                }
                Cell(title: "Audio playlist (URNs)") {
                    PlaylistView(templates: URNPlaylist.audios)
                }
                Cell(title: "Playlist (with one error)") {
                    PlaylistView(templates: URNPlaylist.videosWithOneError)
                }
                Cell(title: "Playlist (with errors)") {
                    PlaylistView(templates: URNPlaylist.videosWithErrors)
                }
                Cell(title: "Playlist (Empty)") {
                    PlaylistView(templates: [])
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
