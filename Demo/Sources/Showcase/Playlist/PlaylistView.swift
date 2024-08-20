//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct PlaylistItemsView: View {
    @ObservedObject var player: Player

    var body: some View {
        List($player.items, id: \.self, editActions: .all, selection: $player.currentItem) { item in
            Text(item.id.uuidString)
        }
    }
}

struct PlaylistView: View {
    let templates: [Template]

    @StateObject private var model = PlaylistViewModel.persisted ?? PlaylistViewModel()
    @State private var layout: PlaybackView.Layout = .minimized

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player, layout: $layout)
                .monoscopic(model.isMonoscopic)
                .supportsPictureInPicture()
#if os(iOS)
            if layout != .maximized {
                PlaylistItemsView(player: model.player)
            }
#endif
        }
        .animation(.defaultLinear, value: layout)
        .onAppear {
            model.templates = templates
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
    PlaylistView(templates: [
        URLTemplate.onDemandVideoLocalHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.dvrVideoHLS
    ])
}
