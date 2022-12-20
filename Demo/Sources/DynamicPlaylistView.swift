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
            ForEach(mutableMedias) { media in
                MediaView(media: media)
            }
            .onMove(perform: move)
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
}

// Behavior: h-hug, v-hug
private struct MediaView: View {
    let media: Media
    
    var body: some View {
        switch media {
        case .empty:
            EmptyView()
        case .url(let url), .unbufferedUrl(let url):
            Text(url.absoluteString)
        case .urn(let urn):
            Text(urn)
        }
    }
}

// MARK: Previews

struct DynamicPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicPlaylistView(medias: [
            MediaURL.onDemandVideoLocalHLS,
            MediaURL.onDemandVideoLocalHLS,
        ])
    }
}
