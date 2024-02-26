//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

/// A standalone player view with standard controls.
/// Behavior: h-exp, v-exp
struct PlayerView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    private var isMonoscopic = false
    private var supportsPictureInPicture = false

    var body: some View {
        PlaybackView(player: model.player)
            .monoscopic(media.isMonoscopic)
            .supportsPictureInPicture(supportsPictureInPicture)
            .enabledForInAppPictureInPicture(persisting: model)
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

extension PlayerView {
    func monoscopic(_ isMonoscopic: Bool = true) -> PlayerView {
        var view = self
        view.isMonoscopic = isMonoscopic
        return view
    }

    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> PlayerView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}

extension PlayerView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    PlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
