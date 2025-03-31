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
        .accessibilityElement()
        .accessibilityLabel(media.title)
    }
}

private struct Toolbar: View {
    @ObservedObject private var player: Player
    @ObservedObject private var model: PlaylistViewModel
    @State private var isSelectionPresented = false

    private var repeatModeImageName: String {
        switch player.repeatMode {
        case .off:
            "repeat.circle"
        case .one:
            "repeat.1.circle.fill"
        case .all:
            "repeat.circle.fill"
        }
    }

    private var repeatModeAccessibilityLabel: String {
        switch player.repeatMode {
        case .off:
            "Repeat none"
        case .one:
            "Repeat current"
        case .all:
            "Repeat all"
        }
    }

    var body: some View {
        HStack {
            previousButton()
            Spacer()
            managementButtons()
            Spacer()
            nextButton()
        }
        .padding()
        .sheet(isPresented: $isSelectionPresented) {
            NavigationStack {
                PlaylistSelectionView(model: model)
            }
        }
    }

    init(model: PlaylistViewModel) {
        self.player = model.player
        self.model = model
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
                Toolbar(model: model)
                list()
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

    @ViewBuilder
    private func list() -> some View {
        ZStack {
            if !model.medias.isEmpty {
                List($model.medias, id: \.self, editActions: .all, selection: $model.currentMedia) { $media in
                    MediaCell(media: media)
                }
            }
            else {
                MessageView(message: "No items", icon: .none)
            }
        }
        .animation(.linear, value: model.medias)
    }
}

private extension Toolbar {
    func previousButton() -> some View {
        Button(action: player.returnToPrevious) {
            Image(systemName: "arrow.left")
        }
        .hoverEffect()
        .accessibilityLabel("Previous")
        .disabled(!player.canReturnToPrevious())
    }

    func managementButtons() -> some View {
        HStack(spacing: 30) {
            repeatModeButton()
            shuffleButton()
            addButton()
            trashButton()
        }
    }

    func nextButton() -> some View {
        Button(action: player.advanceToNext) {
            Image(systemName: "arrow.right")
        }
        .hoverEffect()
        .accessibilityLabel("Next")
        .disabled(!player.canAdvanceToNext())
    }
}

private extension Toolbar {
    func repeatModeButton() -> some View {
        Button(action: toggleRepeatMode) {
            Image(systemName: repeatModeImageName)
        }
        .hoverEffect()
        .accessibilityLabel(repeatModeAccessibilityLabel)
    }

    func shuffleButton() -> some View {
        Button(action: model.shuffle) {
            Image(systemName: "shuffle")
        }
        .hoverEffect()
        .accessibilityLabel("Shuffle")
        .disabled(model.isEmpty)
    }

    func addButton() -> some View {
        Button(action: add) {
            Image(systemName: "plus")
        }
        .hoverEffect()
        .accessibilityLabel("Add")
    }

    func trashButton() -> some View {
        Button(action: model.trash) {
            Image(systemName: "trash")
        }
        .hoverEffect()
        .accessibilityLabel("Delete all")
        .disabled(model.isEmpty)
    }

    private func toggleRepeatMode() {
        switch player.repeatMode {
        case .off:
            player.repeatMode = .all
        case .one:
            player.repeatMode = .off
        case .all:
            player.repeatMode = .one
        }
    }

    private func add() {
        isSelectionPresented.toggle()
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
