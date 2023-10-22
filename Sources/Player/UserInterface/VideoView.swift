//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI
import UIKit

public final class VideoLayerView: UIView {
    let playerLayer: AVPlayerLayer

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
        super.init(frame: .zero)
        layer.addSublayer(self.playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = bounds
    }
}

/// A view displaying video content provided by an associated player.
/// 
/// Behavior: h-exp, v-exp
public struct VideoView: UIViewRepresentable {
    @ObservedObject private var player: Player
    private let pictureInPicture: PictureInPicture?
    private let gravity: AVLayerVideoGravity

    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect, pictureInPicture: PictureInPicture? = nil) {
        self.player = player
        self.gravity = gravity
        self.pictureInPicture = pictureInPicture
    }

    public func makeUIView(context: Context) -> VideoLayerView {
        let layer = AVPlayerLayer(player: player.queuePlayer)
        let view = VideoLayerView(playerLayer: pictureInPicture?.currentLayer ?? layer)
        view.backgroundColor = .clear
        view.player = player.queuePlayer
        pictureInPicture?.attach(playerLayer: view.playerLayer)
        return view
    }

    public func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity
    }
}
