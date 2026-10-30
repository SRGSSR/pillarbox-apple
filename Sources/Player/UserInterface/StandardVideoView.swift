//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

struct StandardVideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity
    let supportsPictureInPicture: Bool

    static func dismantleUIView(_ uiView: VideoHostView, coordinator: Void) {
        PictureInPicture.shared.custom.dismantleHostView(uiView)
    }

    func makeUIView(context: Context) -> VideoHostView {
        PictureInPicture.shared.custom.makeHostView(for: player, supportsPictureInPicture: supportsPictureInPicture)
    }

    func updateUIView(_ uiView: VideoHostView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.gravity = gravity
        PictureInPicture.shared.custom.updateHostView(uiView, supportsPictureInPicture: supportsPictureInPicture)
    }
}
