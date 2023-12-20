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

    @StateObject private var model = PlayerViewModel.shared ?? PlayerViewModel()

    var body: some View {
        SystemVideoView(player: model.player)
            .supportsPictureInPicture()
            .supportsInAppPictureInPicture(model)
            .ignoresSafeArea()
            .onAppear(perform: play)
            .tracked(name: "system-player")
    }

    private func play() {
        model.media = media
        model.play()
    }
}

extension SystemPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    SystemPlayerView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
