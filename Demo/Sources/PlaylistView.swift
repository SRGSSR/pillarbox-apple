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
    @State var medias: [Media]

    var body: some View {
        VStack(spacing: 0) {
            PlayerViewImp(player: model.player)
            ListView(model: model)
        }
        .onAppear { model.medias = medias }
        .onChange(of: medias) { newValue in
            model.medias = newValue
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
                PlaylistCell(media: media, isPlaying: media == model.currentMedia)
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
private struct PlaylistCell: View {
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
    @State private var mediasSelected: Set<Media> = []
    @State private var editMode = EditMode.active
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(model.availableMedias, id: \.self, selection: $mediasSelected) { media in
                Text(media.title)
            }
            .environment(\.editMode, $editMode)
            .navigationBarTitle("Add a stream to the playlist")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationBarItems(leading: Button("Cancel", action: cancel))
            .navigationBarItems(trailing: Button("Add", action: { add() }))
        }
    }

    private func cancel() {
        mediasSelected = []
        dismiss()
    }

    @MainActor
    private func add() {
        model.add(Array(mediasSelected))
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
        PlaylistView(medias: [
            MediaURL.onDemandVideoLocalHLS,
            MediaURL.shortOnDemandVideoHLS,
            MediaURL.dvrVideoHLS,
        ])
    }
}
