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
