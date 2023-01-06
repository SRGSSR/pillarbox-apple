//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct PlaylistView: View {
    @StateObject private var model = PlaylistViewModel()
    @State var templates: [Template]

    var body: some View {
        VStack(spacing: 0) {
            PlayerViewImp(player: model.player)
            ListView(model: model)
        }
        .onAppear { model.templates = templates }
        .onChange(of: templates) { newValue in
            model.templates = newValue
        }
    }
}

// Behavior: h-exp, v-exp
private struct ListView: View {
    @ObservedObject var model: PlaylistViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ShufflePlaylistButton(model: model)
                AddMediaButton(model: model)
                LoadNewPlaylistButton(model: model)
            }
            List($model.medias, id: \.self, editActions: .all, selection: $model.currentMedia) { $media in
                MediaCell(media: media, isPlaying: media == model.currentMedia)
            }
        }
    }
}

// Behavior: h-hug, v-hug
private struct PlayingIndicatorView: View {
    let isVisible: Bool
    
    var body: some View {
        Group {
            if isVisible {
                Image(systemName: "play.circle")
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: 30, maxHeight: 30)
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
            PlayingIndicatorView(isVisible: isPlaying)
        }
    }
}

// Behavior: h-exp, v-exp
private struct AddMediaButton: View {
    let model: PlaylistViewModel
    @State private var isSelectionPlaylistPresented = false

    var body: some View {
        HStack {
            Spacer()
            Button {
                isSelectionPlaylistPresented.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .frame(width: 30, height: 30)
            .foregroundColor(.accentColor)
            .sheet(isPresented: $isSelectionPlaylistPresented, onDismiss: nil, content: {
                PlaylistSelectionView(model: model)
            })
            Spacer()
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
                section(name: "Original items", templates: model.templates)
                section(name: "Standard items", templates: model.otherStandardTemplates)
            }
            .environment(\.editMode, .constant(.active))
            .navigationBarTitle("Add a stream to the playlist")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationBarItems(leading: Button("Cancel", action: cancel))
            .navigationBarItems(trailing: Button("Add", action: { add() }))
        }
    }

    private func section(name: String, templates: [Template]) -> some View {
        Group {
            if !templates.isEmpty {
                Section(name) {
                    ForEach(templates, id: \.self) { media in
                        Text(media.title)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    private func cancel() {
        selectedTemplates = []
        dismiss()
    }

    @MainActor
    private func add() {
        model.add(from: Array(selectedTemplates))
        cancel()
    }
}

// Behavior: h-exp, v-exp
private struct ShufflePlaylistButton: View {
    @ObservedObject var model: PlaylistViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                model.shuffle()
            }) {
                Image(systemName: "shuffle")
            }
            Spacer()
        }
    }
}

// Behavior: h-exp, v-exp
private struct LoadNewPlaylistButton: View {
    @ObservedObject var model: PlaylistViewModel

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                model.reload()
            }) { Image(systemName: "arrow.triangle.2.circlepath") }
            Spacer()
        }
        .padding(10)
    }
}

// MARK: Previews

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(templates: [
            URLTemplate.onDemandVideoLocalHLS,
            URLTemplate.shortOnDemandVideoHLS,
            URLTemplate.dvrVideoHLS,
        ])
    }
}
