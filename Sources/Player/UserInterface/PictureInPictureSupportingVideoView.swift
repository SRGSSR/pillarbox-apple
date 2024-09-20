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
        PictureInPicture.shared.custom.dismantleVideoLayerView(hostedBy: uiView)
    }

    func makeUIView(context: Context) -> PictureInPictureHostView {
        let view = PictureInPictureHostView()
        view.addLayerView(PictureInPicture.shared.custom.makeVideoLayerView(hostedBy: view, for: player))
        return view
    }

    func updateUIView(_ uiView: PictureInPictureHostView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.gravity = gravity
    }
}
