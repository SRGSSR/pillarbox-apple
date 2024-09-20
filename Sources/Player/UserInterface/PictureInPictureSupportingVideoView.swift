//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

class HostView: UIView {
    var layerView: VideoLayerView

    init(layerView: VideoLayerView) {
        self.layerView = layerView
        super.init(frame: .zero)
        addSubview(layerView)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: layerView.trailingAnchor),
            topAnchor.constraint(equalTo: layerView.topAnchor),
            bottomAnchor.constraint(equalTo: layerView.bottomAnchor)
        ])
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        guard subview === layerView else { return }

        let layerView = VideoLayerView()
        layerView.player = self.layerView.player
        layerView.playerLayer.videoGravity = self.layerView.playerLayer.videoGravity
        self.layerView = layerView
        addSubview(layerView)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: layerView.trailingAnchor),
            topAnchor.constraint(equalTo: layerView.topAnchor),
            bottomAnchor.constraint(equalTo: layerView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct PictureInPictureSupportingVideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIView(_ uiView: HostView, coordinator: Void) {
        PictureInPicture.shared.custom.relinquish(for: uiView)
    }

    func makeUIView(context: Context) -> HostView {
        if let lastLayerView = PictureInPicture.shared.custom.lastLayerView {
            if lastLayerView.player === player.queuePlayer {
                print("--> reuse last layer view")
                let view = HostView(layerView: lastLayerView)
                PictureInPicture.shared.custom.acquire(for: view)
                return view
            }
            else {
                print("--> create new layer view (reg)")
                let view = HostView(layerView: .init())
                PictureInPicture.shared.custom.register(for: view)
                return view
            }
        }
        else {
            print("--> create new layer view (acq)")
            let view = HostView(layerView: .init())
            PictureInPicture.shared.custom.acquire(for: view)
            return view
        }
    }

    func updateUIView(_ uiView: HostView, context: Context) {
        uiView.layerView.player = player.queuePlayer
        uiView.layerView.playerLayer.videoGravity = gravity
    }
}
