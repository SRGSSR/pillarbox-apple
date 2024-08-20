//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct MediaCell: View {
    let media: Media?

    var body: some View {
        VStack(alignment: .leading) {
            Text(media?.title ?? "-")
            if let subtitle = media?.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct Toolbar: View {
    @ObservedObject var player: Player
    @ObservedObject var model: PlaylistViewModel

    @State private var isMediaSelectionPresented = false

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
        .sheet(isPresented: $isMediaSelectionPresented) {
            Color.red
            // MediaSelectionView(model: model)
        }
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
        isMediaSelectionPresented.toggle()
    }
}


private struct PlaylistItemsView: View {
    @ObservedObject var player: Player
    let model: PlaylistViewModel

    var body: some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { item in
            MediaCell(media: model.media(for: item.wrappedValue))
        }
    }
}

struct PlaylistView: View {
    let medias: [Media]

    @StateObject private var model = PlaylistViewModel.persisted ?? PlaylistViewModel()
    @State private var layout: PlaybackView.Layout = .minimized

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player, layout: $layout)
                .monoscopic(model.isMonoscopic)
                .supportsPictureInPicture()
#if os(iOS)
            if layout != .maximized {
                Toolbar(player: model.player, model: model)
                PlaylistItemsView(player: model.player, model: model)
            }
#endif
        }
        .animation(.defaultLinear, value: layout)
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
