//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

/*
private struct _PlaylistView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var player: Player
    @ObservedObject var viewModel: PlaylistViewModel

    var body: some View {
        List(Array(zip(player.items, viewModel.entries)), id: \.0) { item, entry in
            Button {
                player.currentItem = item
            } label: {
                Text(entry.media.title)
                    .bold(item == player.currentItem)
                    .foregroundStyle(item == player.currentItem ? Color.primary : Color.secondary)
            }
        }
    }
}
 */

struct PlayerView: View {
    let media: Media
    var supportsPictureInPicture = false
    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    var body: some View {
        PlaybackView(player: model.player)
            .enabledForInAppPictureInPicture(persisting: model)
            .background(.black)
            .onAppear(perform: play)
            .tracked(name: "player")
    }

    init(media: Media) {
        self.media = media
    }

    private func play() {
        model.media = media
        model.play()
    }
}
