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

    static func dismantleUIView(_ uiView: VideoLayerView, coordinator: Void) {
        PictureInPicture.shared.custom.relinquish(for: uiView)
    }

    func makeUIView(context: Context) -> VideoLayerView {
        if let availableView = PictureInPicture.shared.custom.refs.last?.view, availableView.superview == nil {
            PictureInPicture.shared.custom.acquire(for: availableView)
            return availableView
        }
        else {
            let view = VideoLayerView()
            PictureInPicture.shared.custom.acquire(for: view)
            return view
        }
    }

    func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity
    }
}
