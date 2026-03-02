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
        URLMedia.apple_360,
        URLMedia.unauthorized,
        URLMedia.unknown,
        URLMedia.unavailableMp3,
        URNMedia.unknown
    ]

    let model: PlaylistViewModel

    @State private var selectedMedias: Set<Media> = []
    @State private var selectedInsertionOption: InsertionOption = .append
    @State private var multiplier = 1

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            picker()
            list()
            stepper()
        }
        .environment(\.editMode, .constant(.active))
        .navigationBarTitle("Add content")
        .navigationBarTitleDisplayMode(.inline)
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

    private func picker() -> some View {
        SwiftUI.Picker(selection: $selectedInsertionOption) {
            ForEach(InsertionOption.allCases, id: \.self) { option in
                Text(option.name)
                    .tag(option)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func list() -> some View {
        List(Self.medias, id: \.self, selection: $selectedMedias) { media in
            Text(media.title)
        }
    }

    private func stepper() -> some View {
        Stepper(value: $multiplier, in: 1...100) {
            LabeledContent("Multiplier", value: "×\(multiplier)")
        }
        .padding()
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        let entries = Array(repeating: selectedMedias, count: multiplier).flatMap(\.self).map(PlaylistEntry.init)
        switch selectedInsertionOption {
        case .prepend:
            model.prepend(entries)
        case .insertBefore:
            model.insertBeforeCurrent(entries)
        case .insertAfter:
            model.insertAfterCurrent(entries)
        case .append:
            model.append(entries)
        }
        dismiss()
    }
}

private extension PlaylistSelectionView {
    enum InsertionOption: CaseIterable {
        case prepend
        case insertBefore
        case insertAfter
        case append

        var name: LocalizedStringResource {
            switch self {
            case .prepend:
                "Prepend"
            case .insertBefore:
                "Insert before"
            case .insertAfter:
                "Insert after"
            case .append:
                "Append"
            }
        }
    }
}
