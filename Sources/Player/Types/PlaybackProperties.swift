//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct PlaybackProperties: Equatable {
    static let empty = Self(rate: 0, isExternalPlaybackActive: false, isMuted: false)

    let rate: Float
    let isExternalPlaybackActive: Bool
    let isMuted: Bool
}
