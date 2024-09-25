//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

struct BasicVideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    func makeUIView(context: Context) -> VideoLayerView {
        .init()
    }

    func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.gravity = gravity
    }
}
