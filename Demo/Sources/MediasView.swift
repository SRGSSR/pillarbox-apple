//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

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
            PlayerView(media: media)
        }
    }

    private func play() {
        isPlayerPresented.toggle()
    }
}

struct MediasView: View {
    private let medias = [
        Media(
            id: "assets:vod_hls",
            title: "VOD - HLS",
            description: "Switzerland says sorry! The fondue invasion",
            source: .url(URL(string: "https://swi-vod.akamaized.net/videoJson/47603186/master.m3u8")!)
        ),
        Media(
            id: "assets:vod_hls_short",
            title: "VOD - HLS (short)",
            description: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
            source: .url(URL(string: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")!)
        ),
        Media(
            id: "assets:vod_mp4",
            title: "VOD - MP4",
            description: "The dig",
            source: .url(URL(string: "https://media.swissinfo.ch/media/video/dddaff93-c2cd-4b6e-bdad-55f75a519480/rendition/154a844b-de1d-4854-93c1-5c61cd07e98c.mp4")!)
        ),
        Media(
            id: "assets:video_live_hls",
            title: "Video livestream - HLS",
            description: "Couleur 3 en vidéo",
            source: .url(Stream.couleur3_livestream)
        ),
        Media(
            id: "assets:video_live_dvr_hls",
            title: "Video livestream with DVR - HLS",
            description: "Couleur 3 en vidéo",
            source: .url(Stream.couleur3_livestream_dvr)
        ),
        Media(
            id: "assets:video_live_dvr_timestamps_hls",
            title: "Video livestream with DVR and timestamps - HLS",
            description: "Tageschau",
            source: .url(URL(string: "https://tagesschau.akamaized.net/hls/live/2020115/tagesschau/tagesschau_1/master.m3u8")!)
        ),
        Media(
            id: "assets:aod_mp3",
            title: "AOD - MP3",
            description: "On en parle",
            source: .url(URL(string: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")!)
        ),
        Media(
            id: "assets:audio_live_mp3",
            title: "Audio livestream - MP3",
            description: "Couleur 3",
            source: .url(URL(string: "http://stream.srg-ssr.ch/m/couleur3/mp3_128")!)
        ),
        Media(
            id: "assets:audio_live_dvr_hls",
            title: "Audio livestream with DVR - HLS",
            description: "Couleur 3",
            source: .url(URL(string: "https://lsaplus.swisstxt.ch/audio/couleur3_96.stream/playlist.m3u8")!)
        ),
        Media(
            id: "assets:vod_hls_16_9_urn",
            title: "VOD 16:9 - HLS (URN)",
            description: "Le 19h30",
            source: .urn("urn:rts:video:6820736")
        ),
        Media(
            id: "assets:vod_hls_1_1_urn",
            title: "VOD 1:1 - HLS (URN)",
            description: "Test carré",
            source: .urn("urn:rts:video:8393241")
        ),
        Media(
            id: "assets:vod_hls_9_16_urn",
            title: "VOD 9:16 - HLS (URN)",
            description: "Test 9:16",
            source: .urn("urn:rts:video:8412286")
        ),
        Media(
            id: "assets:audio_live_dvr_hls_urn",
            title: "Audio livestream with DVR - HLS (URN)",
            description: "Couleur 3 en direct",
            source: .urn("urn:rts:audio:3262363")
        ),
        Media(
            id: "assets:aod_mp3_urn",
            title: "AOD - MP3 (URN)",
            description: "Il lavoro di TerraProject per una fotografia documentaria",
            source: .urn("urn:rsi:audio:8833144")
        ),
        Media(
            id: "assets:apple_basic_4_3",
            title: "Apple Basic 4:3",
            description: "4x3 aspect ratio, H.264 @ 30Hz",
            source: .url(Stream.appleBasic_4_3)
        ),
        Media(
            id: "assets:apple_basic_16_9",
            title: "Apple Basic 16:9",
            description: "16x9 aspect ratio, H.264 @ 30Hz",
            source: .url(Stream.appleBasic_16_9)
        ),
        Media(
            id: "assets:apple_advanced_16_9_ts",
            title: "Apple Advanced 16:9 (TS)",
            description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
            source: .url(Stream.appleAdvanced_16_9_ts)
        ),
        Media(
            id: "assets:apple_advanced_16_9_fmp4",
            title: "Apple Advanced 16:9 (fMP4)",
            description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
            source: .url(Stream.appleAdvanced_16_9_fMP4)
        ),
        Media(
            id: "assets:apple_advanced_16_9_hevc_h264",
            title: "Apple Advanced 16:9 (HEVC/H.264)",
            description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
            source: .url(Stream.appleAdvanced_16_9_HEVC_h264)
        ),
        Media(
            id: "assets:unknown",
            title: "Unknown media",
            description: "This media does not exist",
            source: .urn("urn:srf:video:unknown")
        ),
        Media(
            id: "assets:empty",
            title: "Empty",
            description: "No media is provided",
            source: .empty
        )
    ]

    var body: some View {
        List(medias) { media in
            MediaCell(media: media)
        }
        .navigationTitle("Medias")
    }
}

// MARK: Preview

struct MediasView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MediasView()
        }
    }
}
