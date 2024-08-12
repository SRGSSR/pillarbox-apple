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
    /// The ``TrackerAdapter`` is affected by ``Player/isTrackingEnabled``.
    case optional

    /// Mandatory tracking.
    ///
    /// The ``TrackerAdapter`` is not affected by  ``Player/isTrackingEnabled``.
    case mandatory
}
