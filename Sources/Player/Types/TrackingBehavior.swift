//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A tracking behavior.
///
/// Determines how a ``TrackerAdapter`` is affected by the ``Player/isTrackingEnabled`` player setting.
public enum TrackingBehavior {
    /// Optional tracking.
    ///
    /// The ``TrackerAdapter`` takes into account the ``Player/isTrackingEnabled`` player setting.
    case optional

    /// Mandatory tracking.
    ///
    /// The ``TrackerAdapter`` ignores the ``Player/isTrackingEnabled`` player setting.
    case mandatory
}
