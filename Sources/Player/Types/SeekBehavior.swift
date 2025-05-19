//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A behavior specifying how progress updates are handled during seek operations.
public enum SeekBehavior {
    /// Performs seeks to provide the best experience based on the content type.
    ///
    /// For video content, this enables features such as Trick mode or frame-accurate seeking when supported.
    /// Use this when immediate feedback is desirable during seeks.
    case optimal

    /// Defers progress updates until the seek operation completes.
    ///
    /// Typically used in situations where immediate feedback isn’t necessary or when using alternatives like
    /// sprite sheets for seek previews at the user interface level.
    case deferred
}
