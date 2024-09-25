//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import AVKit
import UIKit

final class VideoLayerView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    lazy var contentSource: AVPictureInPictureController.ContentSource = {
        .init(playerLayer: playerLayer)
    }()

    var player: Player? {
        didSet {
            playerLayer.player = player?.queuePlayer
        }
    }

    var gravity: AVLayerVideoGravity {
        get {
            playerLayer.videoGravity
        }
        set {
            playerLayer.videoGravity = newValue
        }
    }

    func duplicate() -> Self {
        let duplicate = Self()
        duplicate.player = player
        duplicate.gravity = gravity
        return duplicate
    }
}
