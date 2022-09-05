//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

struct DemosView: View {
    private let medias = [
        Media(
            id: "assets:vod_hls",
            title: "VOD - HLS",
            description: "Switzerland says sorry! The fondue invasion",
            url: URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!
        ),
        Media(
            id: "assets:vod_hls_short",
            title: "VOD - HLS (short)",
            description: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
            url: URL(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!
        ),
        Media(
            id: "assets:vod_mp4",
            title: "VOD - MP4",
            description: "The dig",
            url: URL(string: "https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")!
        ),
        Media(
            id: "assets:video_live_hls",
            title: "Video livestream - HLS",
            description: "Couleur 3 en vidéo",
            url: URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
        ),
        Media(
            id: "assets:video_live_dvr_hls",
            title: "Video livestream with DVR - HLS",
            description: "Couleur 3 en vidéo",
            url: URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")!
        ),
        Media(
            id: "assets:video_live_dvr_timestamps_hls",
            title: "Video livestream with DVR and timestamps - HLS",
            description: "Tageschau",
            url: URL(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!
        ),
        Media(
            id: "assets:aod_mp3",
            title: "AOD - MP3",
            description: "On en parle",
            url: URL(string: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")!
        ),
        Media(
            id: "assets:audio_live_mp3",
            title: "Audio livestream - MP3",
            description: "Couleur 3",
            url: URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!
        ),
        Media(
            id: "assets:audio_live_dvr_hls",
            title: "Audio livestream with DVR - HLS",
            description: "Couleur 3",
            url: URL(string: "https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")!
        )
    ]

    var body: some View {
        List(medias) { media in
            MediaCell(media: media)
        }
        .navigationTitle("Demos")
    }
}

// MARK: Types

private extension DemosView {
    private struct Media: Identifiable {
        let id: String
        let title: String
        let description: String
        let url: URL
    }
}

// MARK: Cells

private extension DemosView {
    private struct MediaCell: View {
        let media: Media
        @State var isPlayerPresented = false

        var body: some View {
            Button(action: play) {
                VStack(alignment: .leading) {
                    Text(media.title)
                        .foregroundColor(.primary)
                    Text(media.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $isPlayerPresented) {
                PlayerView(url: media.url)
            }
        }

        private func play() {
            isPlayerPresented.toggle()
        }
    }
}

// MARK: Preview

struct DemosView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DemosView()
        }
    }
}
