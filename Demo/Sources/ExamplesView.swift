//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: Cells

// Behavior: h-hug, v-hug
private struct MediaCell: View {
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
    private let medias = Template.medias(from: [
        URLTemplate.onDemandVideoHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.onDemandVideoMP4,
        URLTemplate.liveVideoHLS,
        URLTemplate.dvrVideoHLS,
        URLTemplate.liveTimestampVideoHLS,
        URLTemplate.onDemandAudioMP3,
        URLTemplate.liveAudioMP3,
        URNTemplate.onDemandHorizontalVideo,
        URNTemplate.onDemandSquareVideo,
        URNTemplate.onDemandVerticalVideo,
        URNTemplate.liveVideo,
        URNTemplate.dvrVideo,
        URNTemplate.dvrAudio,
        URNTemplate.onDemandAudio,
        URLTemplate.appleBasic_4_3_HLS,
        URLTemplate.appleBasic_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_fMP4_HLS,
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS,
        URNTemplate.tokenProtectedVideo,
        URNTemplate.superfluouslyTokenProtectedVideo,
        URNTemplate.drmProtectedVideo,
        URNTemplate.expired,
        URNTemplate.unknown
    ])

    var body: some View {
        List(medias) { media in
            MediaCell(media: media)
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
