//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI
import UIKit

public final class VideoLayerView: UIView {
    let playerLayer: AVPlayerLayer

    init(from playerLayer: AVPlayerLayer? = nil) {
        self.playerLayer = playerLayer ?? .init()
        super.init(frame: .zero)
        layer.addSublayer(self.playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}

/// A view displaying video content provided by an associated player.
/// 
/// Behavior: h-exp, v-exp
public struct VideoView: UIViewRepresentable {
    @ObservedObject private var player: Player

    private let gravity: AVLayerVideoGravity
    private let supportsPictureInPicture: Bool

    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect, supportsPictureInPicture: Bool = false) {
        self.player = player
        self.gravity = gravity
        self.supportsPictureInPicture = supportsPictureInPicture
    }

    public func makeUIView(context: Context) -> VideoLayerView {
        let view = if supportsPictureInPicture {
            VideoLayerView(from: PictureInPicture.shared.playerLayer)
        }
        else {
            VideoLayerView()
        }
        view.backgroundColor = .clear
        view.player = player.queuePlayer
        return view
    }

    public func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity

        // Defer to avoid update loop
        if supportsPictureInPicture {
            DispatchQueue.main.async {
                PictureInPicture.shared.assign(playerLayer: uiView.playerLayer)
            }
        }
    }
}
