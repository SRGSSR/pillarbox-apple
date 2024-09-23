//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

final class PictureInPictureHostView: UIView {
    weak var videoLayerView: VideoLayerView?

    var player: AVPlayer? {
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

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if let videoLayerView, subview === videoLayerView {
            addVideoLayerView(videoLayerView.duplicate())
        }
    }
}
