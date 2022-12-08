//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// An asset representing content to be played.
public enum Asset {
    /// An asset endlessly loading.
    case loading
    /// A simple asset playable from a URL.
    case simple(url: URL)
    /// An asset loaded with custom resource loading.
    case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
    /// An encrypted asset loaded with a content key session.
    case encrypted(url: URL, delegate: AVContentKeySessionDelegate)
    /// An asset immediately failing with an error.
    case failure(error: Error)
}
