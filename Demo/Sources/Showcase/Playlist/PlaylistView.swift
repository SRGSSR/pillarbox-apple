//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
private struct MediaCell: View {
    let media: Media
    let isPlaying: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(media.title)
                if let description = media.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: cancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", action: add)
                        .disabled(selectedTemplates.isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private func section(title: String, templates: [Template]) -> some View {
        if !templates.isEmpty {
            Section(title) {
                ForEach(templates, id: \.self) { template in
                    Text(template.title)
                }
            }
        }
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        model.add(from: Array(selectedTemplates))
        dismiss()
    }
}

// Behavior: h-exp, v-hug
private struct Toolbar: View {
    @ObservedObject var player: Player
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
        .sheet(isPresented: $isSelectionPlaylistPresented) {
            PlaylistSelectionView(model: model)
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
        Button(action: player.advanceToNext) {
            Image(systemName: "arrow.right")
        }
        .disabled(!player.canAdvanceToNext())
    }

    private func add() {
        isSelectionPlaylistPresented.toggle()
    }
}

// Behavior: h-exp, v-exp
struct PlaylistView: View {
    @State var templates: [Template]
    @StateObject private var model = PlaylistViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player)
            Toolbar(player: model.player, model: model)
            List($model.medias, id: \.self, editActions: .all, selection: $model.currentMedia) { $media in
                MediaCell(media: media, isPlaying: media == model.currentMedia)
            }
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
