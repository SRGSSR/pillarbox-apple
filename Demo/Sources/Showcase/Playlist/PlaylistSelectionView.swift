//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct PlaylistSelectionView: View {
    static let medias = [
        URLMedia.onDemandVideoHLS,
        URLMedia.shortOnDemandVideoHLS,
        URLMedia.onDemandVideoMP4,
        URLMedia.liveVideoHLS,
        URLMedia.dvrVideoHLS,
        URLMedia.liveTimestampVideoHLS,
        URLMedia.onDemandAudioMP3,
        URLMedia.liveAudioMP3,
        URNMedia.onDemandHorizontalVideo,
        URNMedia.onDemandSquareVideo,
        URNMedia.onDemandVerticalVideo,
        URNMedia.liveVideo,
        URNMedia.dvrVideo,
        URNMedia.dvrAudio,
        URLMedia.appleBasic_4_3_HLS,
        URLMedia.appleBasic_16_9_TS_HLS,
        URLMedia.appleAdvanced_16_9_TS_HLS,
        URLMedia.appleAdvanced_16_9_fMP4_HLS,
        URLMedia.appleAdvanced_16_9_HEVC_h264_HLS,
        URLMedia.appleWWDCKeynote2023,
        URLMedia.appleDolbyAtmos,
        URLMedia.appleTvMorningShowSeason1Trailer,
        URLMedia.appleTvMorningShowSeason2Trailer,
        URLMedia.uhdVideoHLS,
        URNMedia.gothard_360,
        URLMedia.bitmovin_360,
        URLMedia.unauthorized,
        URLMedia.unknown,
        URLMedia.unavailableMp3,
        URNMedia.expired,
        URNMedia.unknown
    ]

    let model: PlaylistViewModel

    @State private var selectedMedias: Set<Media> = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(Self.medias, id: \.self, selection: $selectedMedias) { media in
            Text(media.title)
        }
        .environment(\.editMode, .constant(.active))
        .navigationBarTitle("Add content")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: add)
                    .disabled(selectedMedias.isEmpty)
            }
        }
        .tracked(name: "selection", levels: ["playlist"])
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        model.add(Array(selectedMedias))
        dismiss()
    }
}
