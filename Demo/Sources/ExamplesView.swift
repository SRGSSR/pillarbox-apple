//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: Cells

// Behavior: h-hug, v-hug
private struct ExampleCell: View {
    let media: Media

    @State var isPlayerPresented = false

    var body: some View {
        Button(action: play) {
            VStack(alignment: .leading) {
                Text(media.title)
                    .foregroundColor(.primary)
                if let description = media.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
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

// MARK: View

// Behavior: h-exp, v-exp
struct ExamplesView: View {
    private let medias = [
        MediaURL.onDemandVideoHLS,
        MediaURL.shortOnDemandVideoHLS,
        MediaURL.onDemandVideoMP4,
        MediaURL.liveVideoHLS,
        MediaURL.dvrVideoHLS,
        MediaURL.liveTimestampVideoHLS,
        MediaURL.onDemandAudioMP3,
        MediaURL.liveAudioMP3,
        MediaURN.onDemandHorizontalVideo,
        MediaURN.onDemandSquareVideo,
        MediaURN.onDemandVerticalVideo,
        MediaURN.liveVideo,
        MediaURN.dvrVideo,
        MediaURN.dvrAudio,
        MediaURN.onDemandAudio,
        MediaURL.appleBasic_4_3_HLS,
        MediaURL.appleBasic_16_9_TS_HLS,
        MediaURL.appleAdvanced_16_9_TS_HLS,
        MediaURL.appleAdvanced_16_9_fMP4_HLS,
        MediaURL.appleAdvanced_16_9_HEVC_h264_HLS,
        MediaURN.tokenProtectedVideo,
        MediaURN.superfluousTokenProtectedVideo,
        MediaURN.drmProtectedVideo,
        MediaURN.expired,
        MediaURN.unknown
    ]

    var body: some View {
        List(medias, id: \.self) { media in
            ExampleCell(media: media)
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
