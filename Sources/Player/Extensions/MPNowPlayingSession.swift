//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import MediaPlayer

extension MPNowPlayingSession {
    private static let unusedSession = MPNowPlayingSession(players: [AVPlayer()])

    func resignActive() {
        Self.unusedSession.becomeActiveIfPossible()
    }

    func isActivePublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.isActive)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
