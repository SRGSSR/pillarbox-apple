//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import MediaPlayer

extension MPNowPlayingSession {
    private static let unusedSession = MPNowPlayingSession(players: [AVPlayer()])

    func resignActive() {
        Self.unusedSession.becomeActiveIfPossible()
    }
}
