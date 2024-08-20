//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

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
                Color.red
            }
#endif
        }
        .animation(.defaultLinear, value: layout)
        .onAppear {
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
