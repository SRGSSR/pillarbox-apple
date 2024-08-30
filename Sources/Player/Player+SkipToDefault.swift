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
    ///
    /// For a livestream supporting DVR this method can be used to check whether the stream is played at the live
    /// edge or not.
    func canSkipToDefault() -> Bool {
        switch streamType {
        case .onDemand, .live:
            return true
        case .dvr where chunkDuration.isValid:
            return time() < seekableTimeRange.end - chunkDuration
        default:
            return false
        }
    }

    /// Returns the current item to its default position.
    /// 
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs
    ///   whether the skip could finish without being cancelled.
    ///
    /// For a livestream supporting DVR the default position corresponds to the live edge.
    func skipToDefault(completion: @escaping (Bool) -> Void = { _ in }) {
        switch streamType {
        case .dvr:
            seek(after(seekableTimeRange.end), smooth: false) { finished in
                completion(finished)
            }
        default:
            seek(near(.zero), smooth: false) { finished in
                completion(finished)
            }
        }
    }
}
