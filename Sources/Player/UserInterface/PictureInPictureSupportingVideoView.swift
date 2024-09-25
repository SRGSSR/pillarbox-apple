//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

struct PictureInPictureSupportingVideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIView(_ uiView: PictureInPictureHostView, coordinator: Void) {
        PictureInPicture.shared.custom.dismantleHostView(uiView)
    }

    func makeUIView(context: Context) -> PictureInPictureHostView {
        PictureInPicture.shared.custom.makeHostView(for: player)
    }

    func updateUIView(_ uiView: PictureInPictureHostView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.gravity = gravity
    }
}
