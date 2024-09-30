//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SpriteKit

/// Lightweight video node subclass to disable automatic un-pause when waking the application from the background.
final class VideoNode: SKVideoNode {
    private let _player: AVPlayer

    override init(avPlayer player: AVPlayer) {
        _player = player
        super.init(avPlayer: player)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isPaused: Bool {
        get {
            super.isPaused
        }
        set {}
    }

    deinit {
        let player = _player
        DispatchQueue.main.async {
            player.play()
        }
    }
}
