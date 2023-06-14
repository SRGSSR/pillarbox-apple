//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension Player {
    /// Returns whether the current player item player can be returned to its default position.
    ///
    /// - Returns: `true` if skipping to the default position is possible.
    func canSkipToDefault() -> Bool {
        switch streamType {
        case .onDemand, .live:
            return true
        case .dvr where chunkDuration.isValid:
            return time < timeRange.end - chunkDuration
        default:
            return false
        }
    }

    /// Returns the current item to its default position.
    /// 
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    func skipToDefault(completion: @escaping (Bool) -> Void = { _ in }) {
        switch streamType {
        case .dvr:
            seek(after(timeRange.end)) { finished in
                completion(finished)
            }
        default:
            seek(near(.zero)) { finished in
                completion(finished)
            }
        }
    }
}
