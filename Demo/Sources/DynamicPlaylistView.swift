//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct DynamicPlaylistView: View {
    @State var medias: [Media]
    @StateObject var player = Player()

    var body: some View {
        VStack(spacing: 0) {
            PlayerView(medias: medias, player: player)
            DynamicListView(medias: medias, player: player)
        }
    }
}

// Behavior: h-exp, v-exp
private struct DynamicListView: View {
    let medias: [Media]
    @State private var mutableMedias: [Media] = []
    @ObservedObject var player: Player
    
    var body: some View {
        List {
            ShufflePlaylistButton(mutableMedias: $mutableMedias, player: player)
            ForEach($mutableMedias, id: \.self, editActions: [.move, .delete]) { media in
                let indexOfCurrentMedia = mutableMedias.firstIndex(of: media.wrappedValue)
                PlaylistCellView(
                    media: media.wrappedValue,
                    isPlaying: indexOfCurrentMedia == indexOfCurrentPlayingItem(),
                    select: select
                )
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
            AddMediaButton(medias: medias, mutableMedias: mutableMedias, completion: add)
        }
        .listStyle(.automatic)
        .onAppear {
            self.mutableMedias = medias
        }
    }
    
    private func move(from: IndexSet, to: Int) {
        if let from = from.map({$0}).first {
            let isMovingDown = from < to
            let isMovingUp = from > to
            let itemToMove = player.items[from]
            if isMovingDown {
                player.move(itemToMove, after: player.items[to-1])
            } else if isMovingUp {
                player.move(itemToMove, before: player.items[to])
            }
        }
        mutableMedias.move(fromOffsets: from, toOffset: to)
    }
    
    private func delete(at: IndexSet) {
        if let at = at.map({$0}).first {
            player.remove(player.items[at])
        }
        mutableMedias.remove(atOffsets: at)
    }
    
    private func add(_ mediasToAdd: [Media]) {
        let mediasToAdd = mediasToAdd.filter { mutableMedias.contains($0) == false } // Remove item if it's already present into the playlist
        mutableMedias += mediasToAdd
        mediasToAdd.map(\.playerItem).forEach { item in
            if let item {
                player.append(item)
            }
        }
    }
    
    private func indexOfCurrentPlayingItem() -> Int? {
        if let item = player.currentItem {
            return player.items.firstIndex(of: item)
        }
        return nil
    }
    
    private func select(_ media: Media) {
        guard
            let playerCurrentItem = player.currentItem,
            let indexOfCurrentPlayingItem = player.items.firstIndex(of: playerCurrentItem),
            let selectIndex = mutableMedias.firstIndex(of: media)
        else { return }
        
        let shiftCount = abs(selectIndex - indexOfCurrentPlayingItem)
        let isMovingForward = selectIndex > indexOfCurrentPlayingItem
        
        (0..<shiftCount).forEach { _ in
            _ = isMovingForward ? player.advanceToNextItem() : player.goBackToPreviousItem()
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
private struct PlaylistCellView: View {
    let media: Media
    let isPlaying: Bool
    let select: (Media) -> Void
    
    var body: some View {
        HStack {
            MediaView(media: media)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .onTapGesture { select(media) }
            PlayingIndicatorView(isVisible: isPlaying)
        }
    }
}

// Behavior: h-exp, v-exp
private struct AddMediaButton: View {
    let medias: [Media]
    let mutableMedias: [Media]
    let completion: ([Media]) -> Void
    @State var isSelectionPlaylistPresented = false
    @State var mediasSelected: Set<Media> = []
    
    
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
            .sheet(isPresented: $isSelectionPlaylistPresented, onDismiss: {
                if mediasSelected.isEmpty == false {
                    completion(Array(mediasSelected))
                }
            }, content: {
                PlaylistSelectionView(medias: medias, mutableMedia: mutableMedias, mediasSelected: $mediasSelected)
            })
            Spacer()
        }
    }
}

// Behavior: h-exp, v-exp
private struct PlaylistSelectionView: View {
    let medias: [Media]
    var mutableMedia: [Media]
    @Binding var mediasSelected: Set<Media>
    @State var editMode = EditMode.active
    
    var body: some View {
        List(medias, id: \.self, selection: $mediasSelected) { media in
            MediaView(media: media)
        }
        .environment(\.editMode, $editMode)
    }
}

// Behavior: h-exp, v-exp
private struct ShufflePlaylistButton: View {
    @Binding var mutableMedias: [Media]
    @ObservedObject var player: Player
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: shuffle) { Image(systemName: "shuffle") }
            Spacer()
        }
    }
    
    private func shuffle() {
        mutableMedias.shuffle()
        player.removeAllItems()
        mutableMedias.compactMap(\.playerItem).forEach { player.append($0) }
    }
}

// MARK: Previews

struct DynamicPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicPlaylistView(medias: [
            MediaURL.onDemandVideoLocalHLS,
            MediaURL.shortOnDemandVideoHLS,
            MediaURL.dvrVideoHLS,
        ])
    }
}
