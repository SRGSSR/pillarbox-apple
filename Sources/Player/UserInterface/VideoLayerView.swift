//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import UIKit

final class VideoLayerView: UIView {
    let playerLayer: AVPlayerLayer

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    init() {
        // Always reuse any player layer available from Picture in Picture, even if the parent video view will not
        // support Picture in Picture. This ensures smooth animation when Picture in Picture is stopped, in all cases.
        // Moreover, if a player layer in Picture in Picture shares the same player with another layer in the app,
        // stopping Picture in Picture pauses the player, which would interfere with playback in the other layer.
        self.playerLayer = PictureInPicture.shared.custom.playerLayer ?? .init()
        super.init(frame: .zero)
        layer.addSublayer(self.playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.synchronizeAnimations {
            playerLayer.frame = layer.bounds
        }
    }
}

private extension CALayer {
    func synchronizeAnimations(_ animations: () -> Void) {
        CATransaction.begin()
        if let positionAnimation = animation(forKey: "position") {
            CATransaction.setAnimationDuration(positionAnimation.duration)
            CATransaction.setAnimationTimingFunction(positionAnimation.timingFunction)
        }
        else {
            CATransaction.disableActions()
        }
        animations()
        CATransaction.commit()
    }
}
