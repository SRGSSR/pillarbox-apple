//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension CMTime {
    func clamped(to range: CMTimeRange, offset: CMTime = .zero) -> CMTime {
        guard !range.isEmpty else { return range.start }
        let offsetRange = CMTimeRange(start: range.start, duration: max(range.duration - offset, .zero))
        return CMTimeClampToRange(self, range: offsetRange)
    }
}
