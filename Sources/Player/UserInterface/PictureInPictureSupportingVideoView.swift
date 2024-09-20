//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import AVKit
import SwiftUI

final class HostView: UIView {
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

    func addLayerView(_ layerView: VideoLayerView) {
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
            addLayerView(layerView.duplicate())
        }
    }
}

struct PictureInPictureSupportingVideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIView(_ uiView: HostView, coordinator: Void) {
        PictureInPicture.shared.custom.relinquish(for: uiView)
    }

    func makeUIView(context: Context) -> HostView {
        let view = HostView()
        view.addLayerView(PictureInPicture.shared.custom.acquire(for: view, player: player))
        return view
    }

    func updateUIView(_ uiView: HostView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.gravity = gravity
    }
}
