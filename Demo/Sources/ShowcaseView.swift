//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

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

struct ShowcaseView: View {
    var body: some View {
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
                    PlayerView(medias: MediaURLPlaylist.videos)
                }
                Cell(title: "Playlist (URNs)") {
                    PlayerView(medias: MediaURNPlaylist.videos)
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
