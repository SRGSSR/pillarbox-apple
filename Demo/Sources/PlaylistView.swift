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
            PlayerView(medias: medias, player: model.player)
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
            LoadNewPlaylistButton(mutableMedias: $model.mutableMedias, model: model)
            List {
                ShufflePlaylistButton(mutableMedias: $model.mutableMedias, model: model)
                ForEach($model.mutableMedias, id: \.self, editActions: [.move, .delete]) { media in
                    let indexOfCurrentMedia = model.mutableMedias.firstIndex(of: media.wrappedValue)
                    PlaylistCell(
                        media: media.wrappedValue,
                        isPlaying: indexOfCurrentMedia == indexOfCurrentPlayingItem(),
                        select: select
                    )
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
                AddMediaButton(medias: model.medias, operation: add)
            }
            .listStyle(.automatic)
        }
    }
    
    private func move(from: IndexSet, to: Int) {
        if let from = from.map({$0}).first {
            let isMovingDown = from < to
            let isMovingUp = from > to
            let itemToMove = model.player.items[from]
            if isMovingDown {
                model.player.move(itemToMove, after: model.player.items[to-1])
            } else if isMovingUp {
                model.player.move(itemToMove, before: model.player.items[to])
            }
        }
        model.mutableMedias.move(fromOffsets: from, toOffset: to)
    }
    
    private func delete(at: IndexSet) {
        if let at = at.map({$0}).first {
            model.player.remove(model.player.items[at])
        }
        model.mutableMedias.remove(atOffsets: at)
    }
    
    private func add(_ mediasToAdd: [Media]) {
        let mediasToAdd = mediasToAdd.filter { model.mutableMedias.contains($0) == false } // Remove item if it's already present into the playlist
        model.mutableMedias += mediasToAdd
        mediasToAdd.map(\.playerItem).forEach { item in
            if let item {
                model.player.append(item)
            }
        }
    }
    
    private func indexOfCurrentPlayingItem() -> Int? {
        if let item = model.player.currentItem {
            return model.player.items.firstIndex(of: item)
        }
        return nil
    }
    
    private func select(_ media: Media) {
        guard
            let playerCurrentItem = model.player.currentItem,
            let indexOfCurrentPlayingItem = model.player.items.firstIndex(of: playerCurrentItem),
            let selectIndex = model.mutableMedias.firstIndex(of: media)
        else { return }
        
        let shiftCount = abs(selectIndex - indexOfCurrentPlayingItem)
        let isMovingForward = selectIndex > indexOfCurrentPlayingItem
        
        (0..<shiftCount).forEach { _ in
            _ = isMovingForward ? model.player.advanceToNextItem() : model.player.returnToPreviousItem()
        }
    }
}

// Behavior: h-hug, v-hug
private struct MediaView: View {
    let media: Media
    
    var body: some View {
        switch media {
        case .empty:
            EmptyView()
        case .url(_, let description), .unbufferedUrl(_, let description), .urn(_, let description):
            Text(description ?? "")
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
    let select: (Media) -> Void
    
    var body: some View {
        HStack {
            MediaView(media: media)
            Spacer()
            PlayingIndicatorView(isVisible: isPlaying)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            select(media)
        }
    }
}

// Behavior: h-exp, v-exp
private struct AddMediaButton: View {
    let medias: [Media]
    let operation: ([Media]) -> Void
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
                PlaylistSelectionView(medias: medias, operation: operation)
            })
            Spacer()
        }
    }
}

// Behavior: h-exp, v-exp
private struct PlaylistSelectionView: View {
    let medias: [Media]
    let operation: ([Media]) -> Void
    @State private var mediasSelected: Set<Media> = []
    @State private var editMode = EditMode.active
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(medias, id: \.self, selection: $mediasSelected) { media in
                MediaView(media: media)
            }
            .environment(\.editMode, $editMode)
            .navigationBarTitle("Add a stream to the playlist")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationBarItems(leading: Button("Cancel", action: cancel))
            .navigationBarItems(trailing: Button("Add", action: add))
        }
    }

    private func cancel() {
        mediasSelected = []
        dismiss()
    }

    private func add() {
        operation(Array(mediasSelected))
        cancel()
    }
}

// Behavior: h-exp, v-exp
private struct ShufflePlaylistButton: View {
    @Binding var mutableMedias: [Media]
    @ObservedObject var model: PlaylistViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: shuffle) { Image(systemName: "shuffle") }
            Spacer()
        }
    }
    
    private func shuffle() {
        mutableMedias.shuffle()
        model.player.removeAllItems()
        mutableMedias.compactMap(\.playerItem).forEach { model.player.append($0) }
    }
}

// Behavior: h-exp, v-exp
private struct LoadNewPlaylistButton: View {
    @Binding var mutableMedias: [Media]
    @ObservedObject var model: PlaylistViewModel

    var body: some View {
        HStack {
            Spacer()
            Button(action: getNewPlaylist) { Image(systemName: "arrow.triangle.2.circlepath") }
            Spacer()
        }
        .padding(10)
        .background(.black)
    }

    private func getNewPlaylist() {
        mutableMedias = [
            MediaURLPlaylist.videosWithDescription,
            MediaMixturePlaylist.mix1,
            MediaMixturePlaylist.mix2,
            MediaMixturePlaylist.mix3,
        ][Int.random(in: 0...3)]

        model.player.removeAllItems()
        mutableMedias.compactMap(\.playerItem).forEach { model.player.append($0) }
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
