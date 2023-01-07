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
    private let urlMedias = Template.medias(from: [
        URLTemplate.onDemandVideoHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.onDemandVideoMP4,
        URLTemplate.liveVideoHLS,
        URLTemplate.dvrVideoHLS,
        URLTemplate.liveTimestampVideoHLS,
        URLTemplate.onDemandAudioMP3,
        URLTemplate.liveAudioMP3
    ])

    private let urnMedias = Template.medias(from: [
        URNTemplate.liveVideo,
        URNTemplate.dvrVideo,
        URNTemplate.dvrAudio,
        URNTemplate.tokenProtectedVideo,
        URNTemplate.superfluouslyTokenProtectedVideo,
        URNTemplate.drmProtectedVideo
    ])

    private let aspectRatioMedias = Template.medias(from: [
        URNTemplate.onDemandHorizontalVideo,
        URNTemplate.onDemandSquareVideo,
        URNTemplate.onDemandVerticalVideo
    ])

    private let unbufferedMedias = Template.medias(from: [
        UnbufferedURLTemplate.liveVideo,
        UnbufferedURLTemplate.onDemandAudio,
        UnbufferedURLTemplate.liveAudio
    ])

    private let appleMedias = Template.medias(from: [
        URLTemplate.appleBasic_4_3_HLS,
        URLTemplate.appleBasic_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_fMP4_HLS,
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS
    ])

    private let cornerCaseMedias = Template.medias(from: [
        URNTemplate.expired,
        URNTemplate.unknown
    ])

    var body: some View {
        List {
            section(title: "SRG streams (URLs)", medias: urlMedias)
            section(title: "SRG streams (URNs)", medias: urnMedias)
            section(title: "Apple streams", medias: appleMedias)
            section(title: "Aspect ratios", medias: aspectRatioMedias)
            section(title: "Unbuffered streams", medias: unbufferedMedias)
            section(title: "Corner cases", medias: cornerCaseMedias)
        }
        .navigationTitle("Examples")
    }

    @ViewBuilder
    private func section(title: String, medias: [Media]) -> some View {
        Section(title) {
            ForEach(medias) { media in
                MediaCell(media: media)
            }
        }
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
