//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: Types

private struct Example: Identifiable {
    static let examples: [Self] = [
        .init(
            title: "VOD - HLS",
            description: "Switzerland says sorry! The fondue invasion",
            media: MediaURL.onDemandVideoHLS
        ),
        .init(
            title: "VOD - HLS (short)",
            description: "Des violents orages ont touché Ajaccio, chef-lieu de la Corse, jeudi",
            media: MediaURL.shortOnDemandVideoHLS
        ),
        .init(
            title: "VOD - MP4",
            description: "The dig",
            media: MediaURL.onDemandVideoMP4
        ),
        .init(
            title: "Video livestream - HLS",
            description: "Couleur 3 en vidéo",
            media: MediaURL.liveVideoHLS
        ),
        .init(
            title: "Video livestream with DVR - HLS",
            description: "Couleur 3 en vidéo",
            media: MediaURL.dvrVideoHLS
        ),
        .init(
            title: "Video livestream with DVR and timestamps - HLS",
            description: "Tageschau",
            media: MediaURL.liveTimestampVideoHLS
        ),
        .init(
            title: "AOD - MP3",
            description: "On en parle",
            media: MediaURL.onDemandAudioMP3
        ),
        .init(
            title: "Audio livestream - MP3",
            description: "Couleur 3",
            media: MediaURL.dvrAudioHLS
        ),
        .init(
            title: "VOD 16:9 - HLS (URN)",
            description: "Le 19h30",
            media: MediaURN.onDemandHorizontalVideo
        ),
        .init(
            title: "VOD 1:1 - HLS (URN)",
            description: "Test carré",
            media: MediaURN.onDemandSquareVideo
        ),
        .init(
            title: "VOD 9:16 - HLS (URN)",
            description: "Test 9:16",
            media: MediaURN.onDemandVerticalVideo
        ),
        .init(
            title: "Video livestream - HLS (URN)",
            description: "SRF 1",
            media: MediaURN.liveVideo
        ),
        .init(
            title: "Video livestream with DVR - HLS (URN)",
            description: "RTS 1",
            media: MediaURN.dvrVideo
        ),
        .init(
            title: "Audio livestream with DVR - HLS (URN)",
            description: "Couleur 3 en direct",
            media: MediaURN.dvrAudio
        ),
        .init(
            title: "AOD - MP3 (URN)",
            description: "Il lavoro di TerraProject per una fotografia documentaria",
            media: MediaURN.onDemandAudio
        ),
        .init(
            title: "Apple Basic 4:3",
            description: "4x3 aspect ratio, H.264 @ 30Hz",
            media: MediaURL.appleBasic_4_3_HLS
        ),
        .init(
            title: "Apple Basic 16:9",
            description: "16x9 aspect ratio, H.264 @ 30Hz",
            media: MediaURL.appleBasic_16_9_TS_HLS
        ),
        .init(
            title: "Apple Advanced 16:9 (TS)",
            description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Transport stream",
            media: MediaURL.appleAdvanced_16_9_TS_HLS
        ),
        .init(
            title: "Apple Advanced 16:9 (fMP4)",
            description: "16x9 aspect ratio, H.264 @ 30Hz and 60Hz, Fragmented MP4",
            media: MediaURL.appleAdvanced_16_9_fMP4_HLS
        ),
        .init(
            title: "Apple Advanced 16:9 (HEVC/H.264)",
            description: "16x9 aspect ratio, H.264 and HEVC @ 30Hz and 60Hz",
            media: MediaURL.appleAdvanced_16_9_HEVC_h264_HLS
        ),
        .init(
            title: "VOD, token protection - HLS (URN)",
            description: "Football",
            media: MediaURN.tokenProtectedVideo
        ),
        .init(
            title: "VOD, superfluous token protection - HLS (URN)",
            description: "Ul stralüsc",
            media: MediaURN.superfluousTokenProtectedVideo
        ),
        .init(
            title: "VOD, DRM protection - HLS (URN)",
            description: "Top Models",
            media: MediaURN.drmProtectedVideo
        ),
        .init(
            title: "Expired content",
            description: "This content is not available anymore",
            media: MediaURN.expired
        ),
        .init(
            title: "Unknown content",
            description: "This content does not exist",
            media: MediaURN.unknown
        ),
        .init(
            title: "Empty",
            description: "No content is provided",
            media: .empty
        )
    ]

    let id = UUID()
    let title: String
    let description: String
    let media: Media
}

// MARK: Cells

// Behavior: h-hug, v-hug
private struct ExampleCell: View {
    let example: Example

    @State var isPlayerPresented = false

    var body: some View {
        Button(action: play) {
            VStack(alignment: .leading) {
                Text(example.title)
                    .foregroundColor(.primary)
                Text(example.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $isPlayerPresented) {
            PlayerView(media: example.media)
        }
    }

    private func play() {
        isPlayerPresented.toggle()
    }
}

// MARK: View

// Behavior: h-exp, v-exp
struct ExamplesView: View {
    var body: some View {
        List(Example.examples) { example in
            ExampleCell(example: example)
        }
        .navigationTitle("Examples")
    }
}

// MARK: Preview

struct ExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExamplesView()
        }
    }
}
