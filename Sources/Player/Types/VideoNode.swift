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

    override var isPaused: Bool {
        get {
            super.isPaused
        }
        set {}
    }

    override init(avPlayer player: AVPlayer) {
        _player = player
        super.init(avPlayer: player)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let rate = _player.rate
        DispatchQueue.main.async { [_player] in
            _player.rate = rate
        }
    }
}
