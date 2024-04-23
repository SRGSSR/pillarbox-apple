//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension CMTime {
    func clamped(to range: CMTimeRange, offset: CMTime = .zero) -> CMTime {
        guard range.isValid, self != .invalid else { return .invalid }
        let offsetRange = CMTimeRange(start: range.start, duration: max(range.duration - offset, .zero))
        guard !offsetRange.isEmpty else { return offsetRange.start }
        return CMTimeClampToRange(self, range: offsetRange)
    }

    func after(timeRanges: [CMTimeRange]) -> CMTime? {
        let matchingRanges = timeRanges.filter { $0.containsTime(self) }
        return matchingRanges.map(\.end).max()
    }
}
