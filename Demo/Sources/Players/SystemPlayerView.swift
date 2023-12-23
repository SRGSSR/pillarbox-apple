//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct SystemPlayerView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()
    private var isPictureInPictureSupported = false

    var body: some View {
        SystemVideoView(player: model.player)
            .supportsPictureInPicture(isPictureInPictureSupported)
            .enabledForInAppPictureInPicture(persisting: model)
            .ignoresSafeArea()
            .onAppear(perform: play)
            .tracked(name: "system-player")
    }

    init(media: Media) {
        self.media = media
    }

    private func play() {
        model.media = media
        model.play()
    }
}

extension SystemPlayerView {
    func supportsPictureInPicture(_ isPictureInPictureSupported: Bool = true) -> SystemPlayerView {
        var view = self
        view.isPictureInPictureSupported = isPictureInPictureSupported
        return view
    }
}

extension SystemPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
