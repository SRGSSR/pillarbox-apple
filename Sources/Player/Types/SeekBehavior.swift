//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A behavior for progress updates during a seek operation.
public enum SeekBehavior {
    /// A behavior updating progress immediately during a seek.
    ///
    /// > Note: This behavior is only applied to video content.
    case immediate

    /// A behavior deferring progress update after a seek ends.
    case deferred
}
