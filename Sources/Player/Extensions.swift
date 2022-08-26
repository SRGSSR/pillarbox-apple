//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension NotificationCenter {
    /// The usual notification publisher retains the filter object, potentially creating cycles. The following
    /// publisher avoids this issue while still only observing the filter object (if any), even after it is
    /// eventually deallocated.
    func weakPublisher(for name: Notification.Name, object: AnyObject? = nil) -> AnyPublisher<Notification, Never> {
        let filtered = (object != nil)
        return publisher(for: name)
            .filter { [weak object] notification in
                guard filtered else { return true }
                guard let object, let notificationObject = notification.object as? AnyObject else {
                    return false
                }
                return notificationObject === object
            }
            .eraseToAnyPublisher()
    }
}
