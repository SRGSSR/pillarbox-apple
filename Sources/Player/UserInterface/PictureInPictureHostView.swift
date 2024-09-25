//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

final class PictureInPictureHostView: UIView {
    private(set) weak var videoLayerView: VideoLayerView?

    var player: Player? {
        get {
            videoLayerView?.player
        }
        set {
            videoLayerView?.player = newValue
        }
    }

    var gravity: AVLayerVideoGravity {
        get {
            videoLayerView?.gravity ?? .resizeAspect
        }
        set {
            videoLayerView?.gravity = newValue
        }
    }

    var contentSource: AVPictureInPictureController.ContentSource? {
        videoLayerView?.contentSource
    }

    func addVideoLayerView(_ videoLayerView: VideoLayerView) {
        addSubview(videoLayerView)
        videoLayerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: videoLayerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: videoLayerView.trailingAnchor),
            topAnchor.constraint(equalTo: videoLayerView.topAnchor),
            bottomAnchor.constraint(equalTo: videoLayerView.bottomAnchor)
        ])
        self.videoLayerView = videoLayerView
    }
}
