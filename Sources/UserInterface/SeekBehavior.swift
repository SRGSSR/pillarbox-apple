//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Seek behavior during progress updates.
public enum SeekBehavior {
    /// Seek immediately when updated.
    case immediate
    /// Deferred until interaction ends.
    case deferred
}
