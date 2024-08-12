//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A tracking behavior.
///
/// Determines how a ``TrackerAdapter`` is affected by ``Player/isTrackingEnabled``.
public enum TrackingBehavior {
    /// Optional tracking.
    ///
    /// The ``TrackerAdapter`` can be disabled ``Player/isTrackingEnabled``.
    case optional

    /// Mandatory tracking.
    ///
    /// The ``TrackerAdapter`` can never be disabled with  ``Player/isTrackingEnabled``.
    case mandatory
}
