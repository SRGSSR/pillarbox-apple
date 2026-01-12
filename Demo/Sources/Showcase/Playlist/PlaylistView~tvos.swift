//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private struct _PlaylistView: View {
    @ObservedObject var model: PlaylistViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(model.entries, id: \.self) { entry in
            Button {
                model.currentEntry = entry
            } label: {
                Text(entry.media.title)
                    .bold(entry == model.currentEntry)
                    .foregroundStyle(entry == model.currentEntry ? Color.primary : Color.secondary)
            }
        }
        .padding()
        .infoViewBackground()
    }
}

struct PlaylistView: View {
    let medias: [Media]
    @StateObject private var model = PlaylistViewModel.persisted ?? PlaylistViewModel()

    var body: some View {
        PlaybackView(player: model.player)
            .infoViewTabs(content: infoViewTabsContent)
            .enabledForInAppPictureInPicture(persisting: model)
            .background(.black)
            .onAppear(perform: play)
            .tracked(name: "playlist")
    }

    init(medias: [Media]) {
        self.medias = medias
    }

    private func play() {
        if model.isEmpty {
            model.entries = medias.map { .init(media: $0) }
        }
        model.play()
    }

    @InfoViewTabsContentBuilder
    func infoViewTabsContent() -> InfoViewTabsContent {
        if model.entries.count > 1 {
            Tab(title: "Playlist") {
                _PlaylistView(model: model)
                    .frame(height: 400)
            }
        }
    }
}

#Preview {
    PlaylistView(medias: [URLMedia.onDemandVideoHLS, URLMedia.shortOnDemandVideoHLS, URLMedia.dvrVideoHLS])
}
