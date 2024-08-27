//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct MediaCell: View {
    let media: Media

    var body: some View {
        VStack(alignment: .leading) {
            Text(media.title)
            if let subtitle = media.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct Toolbar: View {
    @ObservedObject private var player: Player
    @ObservedObject private var model: PlaylistViewModel
    @State private var isSelectionPresented = false

    var body: some View {
        HStack {
            previousButton()
            Spacer()
            managementButtons()
            Spacer()
            nextButton()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $isSelectionPresented) {
            PlaylistSelectionView(model: model)
        }
    }

    init(model: PlaylistViewModel) {
        self.player = model.player
        self.model = model
    }

    @ViewBuilder
    private func previousButton() -> some View {
        Button(action: player.returnToPrevious) {
            Image(systemName: "arrow.left")
        }
        .disabled(!player.canReturnToPrevious())
    }

    @ViewBuilder
    private func managementButtons() -> some View {
        HStack(spacing: 30) {
            Button(action: model.shuffle) {
                Image(systemName: "shuffle")
            }
            .disabled(model.isEmpty)

            Button(action: add) {
                Image(systemName: "plus")
            }

            Button(action: model.trash) {
                Image(systemName: "trash")
            }
            .disabled(model.isEmpty)
        }
    }

    @ViewBuilder
    private func nextButton() -> some View {
        Button(action: player.advanceToNext) {
            Image(systemName: "arrow.right")
        }
        .disabled(!player.canAdvanceToNext())
    }

    private func add() {
        isSelectionPresented.toggle()
    }
}

private struct BottomView: View {
    let model: PlaylistViewModel

    var body: some View {
        Toolbar(model: model)
        Playlist(player: model.player, editActions: .all) { source in
            switch source {
            case let media as Media:
                MediaCell(media: media)
            default:
                Color.clear
            }
        }
    }
}

struct PlaylistView: View {
    let medias: [Media]

    @StateObject private var model = PlaylistViewModel.persisted ?? PlaylistViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player, layout: $model.layout)
                .supportsPictureInPicture()
#if os(iOS)
            if model.layout != .maximized {
                BottomView(model: model)
            }
#endif
        }
        .animation(.defaultLinear, value: model.layout)
        .onAppear {
            model.medias = medias
            model.play()
        }
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "playlist")
    }
}

extension PlaylistView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    PlaylistView(medias: [
        URLMedia.onDemandVideoLocalHLS,
        URLMedia.shortOnDemandVideoHLS,
        URLMedia.dvrVideoHLS
    ])
}
