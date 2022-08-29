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
            id: "urn:swi:video:47603186",
            title: "Switzerland says sorry! The fondue invasion",
            url: URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!
        ),
        Media(
            id: "urn:swi:video:47816310",
            title: "Neuchâtel: where one woman broke the male monopoly on politics",
            url: URL(string: "https://swi-vod.akamaized.net/videoJson/47816310/master.m3u8")!
        ),
        Media(
            id: "urn:rts:video:13317145",
            title: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
            url: URL(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!
        ),
        Media(
            id: "urn:rts:video:8841634",
            title: "Couleur 3 en vidéo",
            url: URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")!
        ),
        Media(
            id: "urn:rts:video:8841634_dvr",
            title: "Couleur 3 en vidéo (DVR)",
            url: URL(string: "https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8")!
        ),
        Media(
            id: "urn:rts:audio:3262363",
            title: "La 1ère",
            url: URL(string: "http://stream.srg-ssr.ch/m/la-1ere/mp3_128")!
        ),
        Media(
            id: "urn:rts:audio:3262363_dvr",
            title: "La 1ère (DVR)",
            url: URL(string: "http://lsaplus.swisstxt.ch/audio/rsp_96.stream/playlist.m3u8")!
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
                Text(media.title)
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
        NavigationView {
            DemosView()
        }
        .navigationViewStyle(.stack)
    }
}
