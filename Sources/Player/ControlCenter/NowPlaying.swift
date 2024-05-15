//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Metadata describing what is currently being played.
struct NowPlaying {
    typealias Info = [String: Any]

    static let empty = Self(metadata: .empty, playbackInfo: [:])

    let metadata: PlayerMetadata
    let playbackInfo: Info

    var isEmpty: Bool {
        metadata == .empty && playbackInfo.isEmpty
    }

    var info: Info {
        metadata.nowPlayingInfo.merging(playbackInfo) { _, new in new }
    }
}
