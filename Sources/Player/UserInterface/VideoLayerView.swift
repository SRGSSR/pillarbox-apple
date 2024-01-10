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

    init(from playerLayer: AVPlayerLayer? = nil) {
        self.playerLayer = playerLayer ?? .init()
        super.init(frame: .zero)
        layer.addSublayer(self.playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.synchronizeLayoutChanges {
            playerLayer.frame = layer.bounds
        }
    }
}

private extension CALayer {
    func synchronizeLayoutChanges(_ changes: () -> Void) {
        if let positionAnimation = animation(forKey: "position") {
            CATransaction.begin()
            CATransaction.setAnimationDuration(positionAnimation.duration)
            CATransaction.setAnimationTimingFunction(positionAnimation.timingFunction)
            changes()
            CATransaction.commit()
        }
        else {
            changes()
            sublayers?.forEach { $0.removeAllAnimations() }
        }
    }
}
