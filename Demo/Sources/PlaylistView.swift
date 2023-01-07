//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
private struct ListView: View {
    @ObservedObject var model: PlaylistViewModel

    var body: some View {
        VStack(spacing: 0) {
            Toolbar(model: model)
            List($model.medias, id: \.self, editActions: .all, selection: $model.currentMedia) { $media in
                MediaCell(media: media, isPlaying: media == model.currentMedia)
            }
        }
    }
}

// Behavior: h-exp, v-exp
private struct MediaCell: View {
    let media: Media
    let isPlaying: Bool

    var body: some View {
        HStack {
            Text(media.title)
            Spacer()
            Image(systemName: "play.circle")
                .frame(maxWidth: 30, maxHeight: 30)
                .opacity(isPlaying ? 1 : 0)
        }
    }
}

// Behavior: h-exp, v-exp
private struct PlaylistSelectionView: View {
    let model: PlaylistViewModel
    @State private var selectedTemplates: Set<Template> = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(selection: $selectedTemplates) {
                section(title: "Original items", templates: model.templates)
                section(title: "Standard items", templates: model.otherStandardTemplates)
            }
            .environment(\.editMode, .constant(.active))
            .navigationBarTitle("Add a stream to the playlist")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationBarItems(leading: Button("Cancel", action: cancel))
            .navigationBarItems(trailing: Button("Add", action: add))
        }
    }

    @ViewBuilder
    private func section(title: String, templates: [Template]) -> some View {
        if !templates.isEmpty {
            Section(title) {
                ForEach(templates, id: \.self) { media in
                    Text(media.title)
                }
            }
        }
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        model.add(from: Array(selectedTemplates))
        cancel()
    }
}

// Behavior: h-exp, v-hug
private struct Toolbar: View {
    @ObservedObject var model: PlaylistViewModel
    @State private var isSelectionPlaylistPresented = false

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
        .sheet(isPresented: $isSelectionPlaylistPresented, onDismiss: nil) {
            PlaylistSelectionView(model: model)
        }
    }

    @ViewBuilder
    private func previousButton() -> some View {
        Button(action: model.returnToPreviousItem) {
            Image(systemName: "arrow.left")
        }
        .disabled(!model.canReturnToPreviousItem())
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
            Button(action: model.reload) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .disabled(!model.canReload)
            Button(action: model.trash) {
                Image(systemName: "trash")
            }
            .disabled(model.isEmpty)
        }
    }

    @ViewBuilder
    private func nextButton() -> some View {
        Button(action: model.advanceToNextItem) {
            Image(systemName: "arrow.right")
        }
        .disabled(!model.canAdvanceToNextItem())
    }

    private func add() {
        isSelectionPlaylistPresented.toggle()
    }
}

// Behavior: h-exp, v-exp
struct PlaylistView: View {
    @StateObject private var model = PlaylistViewModel()
    @State var templates: [Template]

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player)
            ListView(model: model)
        }
        .onAppear { model.templates = templates }
        .onChange(of: templates) { newValue in
            model.templates = newValue
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(templates: [
            URLTemplate.onDemandVideoLocalHLS,
            URLTemplate.shortOnDemandVideoHLS,
            URLTemplate.dvrVideoHLS
        ])
    }
}
