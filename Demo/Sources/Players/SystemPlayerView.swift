//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SystemPlayerView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()
    private var supportsPictureInPicture = false

    var body: some View {
        SystemVideoView(player: model.player)
            .supportsPictureInPicture(supportsPictureInPicture)
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
    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> SystemPlayerView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}

#if os(iOS)
extension SystemPlayerView: SourceCodeViewable {
    static let filePath = #file
}
#endif

#Preview {
    SystemPlayerView(media: URLMedia.onDemandVideoLocalHLS)
}
