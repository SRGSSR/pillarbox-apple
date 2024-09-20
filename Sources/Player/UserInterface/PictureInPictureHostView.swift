//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

final class PictureInPictureHostView: UIView {
    weak var layerView: VideoLayerView?

    var player: AVPlayer? {
        get {
            layerView?.player
        }
        set {
            layerView?.player = newValue
        }
    }

    var gravity: AVLayerVideoGravity {
        get {
            layerView?.gravity ?? .resizeAspect
        }
        set {
            layerView?.gravity = newValue
        }
    }

    var contentSource: AVPictureInPictureController.ContentSource? {
        layerView?.contentSource
    }

    func addVideoLayerView(_ layerView: VideoLayerView) {
        addSubview(layerView)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: layerView.trailingAnchor),
            topAnchor.constraint(equalTo: layerView.topAnchor),
            bottomAnchor.constraint(equalTo: layerView.bottomAnchor)
        ])
        self.layerView = layerView
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if let layerView, subview === layerView {
            addVideoLayerView(layerView.duplicate())
        }
    }
}
