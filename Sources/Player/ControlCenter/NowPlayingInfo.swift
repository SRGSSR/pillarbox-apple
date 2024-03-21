//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Metadata describing what is currently being played.
///
/// Refer to the [official documentation](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter#1674387)
/// for a list of available keys.
public typealias NowPlayingInfo = [String: Any]

// TODO: Possibly add convenience helpers for existing keys (keep key access to automatically support values
//       added in future MediaPlayer versions)
