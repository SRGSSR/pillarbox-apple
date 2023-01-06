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
                    SimplePlayerView(media: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS))
                }
                Cell(title: "Unbuffered video livestream") {
                    PlayerView(media: Media(from: UnbufferedURLTemplate.liveVideo))
                }
                Cell(title: "Unbuffered on-demand audio") {
                    PlayerView(media: Media(from: UnbufferedURLTemplate.onDemandAudio))
                }
                Cell(title: "Unbuffered audio livestream") {
                    PlayerView(media: Media(from: UnbufferedURLTemplate.liveAudio))
                }
                Cell(title: "Stories") {
                    StoriesView()
                }
                Cell(title: "Twins") {
                    TwinsView(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
                }
                Cell(title: "Multi") {
                    MultiView(
                        media1: Media(from: URLTemplate.appleBasic_16_9_TS_HLS),
                        media2: Media(from: URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS)
                    )
                }
            }
            Group {
                Cell(title: "Link") {
                    LinkView(media: Media(from: URLTemplate.appleAdvanced_16_9_fMP4_HLS))
                }
                Cell(title: "Wrapped") {
                    WrappedView(media: Media(from: URLTemplate.appleBasic_16_9_TS_HLS))
                }
            }
            Group {
                Cell(title: "Playlist (URLs)") {
                    PlaylistView(templates: URLTemplates.videos)
                }
                Cell(title: "Playlist (URNs)") {
                    PlaylistView(templates: URNTemplates.videos)
                }
                Cell(title: "Playlist (URNs, long)") {
                    PlaylistView(templates: URNTemplates.longVideos)
                }
                Cell(title: "Playlist (URNs, token-protected)") {
                    PlaylistView(templates: URNTemplates.tokenProtectedVideos)
                }
                Cell(title: "Playlist (URNs, DRM-protected)") {
                    PlaylistView(templates: URNTemplates.drmProtectedVideos)
                }
                Cell(title: "Audio playlist (URNs)") {
                    PlaylistView(templates: URNTemplates.audios)
                }
                Cell(title: "Playlist (with one error)") {
                    PlaylistView(templates: URNTemplates.videosWithOneError)
                }
                Cell(title: "Playlist (with errors)") {
                    PlaylistView(templates: URNTemplates.videosWithErrors)
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
