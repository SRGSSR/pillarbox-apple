//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import MediaPlayer

/// Metadata describing what is currently being played.
enum NowPlaying {
    case empty
    case filled(metadata: PlayerMetadata, playbackInfo: Info)

    typealias Info = [String: Any]

    var info: Info {
        switch self {
        case .empty:
            [:]
        case let .filled(metadata, playbackInfo):
            metadata.nowPlayingInfo
                .merging(playbackInfo) { _, new in new }
                // For proper Control Center integration at least one metadata key must be filled.
                .merging([MPMediaItemPropertyTitle: ""]) { old, _ in old }
        }
    }

    var isEmpty: Bool {
        switch self {
        case .empty:
            true
        default:
            false
        }
    }
}
