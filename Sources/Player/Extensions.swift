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
    func weakPublisher<T: AnyObject>(for name: Notification.Name, object: T?) -> AnyPublisher<Notification, Never> {
        if let object {
            return publisher(for: name)
                .weakCapture(object)
                .filter { notification, object in
                    guard let notificationObject = notification.object as? AnyObject else {
                        return false
                    }
                    return notificationObject === object
                }
                .map(\.0)
                .eraseToAnyPublisher()
        }
        else {
            return publisher(for: name)
                .eraseToAnyPublisher()
        }
    }
}

public extension Publisher {
    /// Capture another object weakly and provide one of its properties as additional output. Does not emit when the
    /// object is `nil`.
    func weakCapture<T: AnyObject, V>(_ other: T?, at keyPath: KeyPath<T, V>) -> AnyPublisher<(Output, V), Failure> {
        compactMap { [weak other] output -> (Output, V)? in
            guard let other else { return nil }
            return (output, other[keyPath: keyPath])
        }
        .eraseToAnyPublisher()
    }

    /// Capture another object weakly and provide it as additional output. Does not emit when the object is `nil`.
    func weakCapture<T: AnyObject>(_ other: T?) -> AnyPublisher<(Output, T), Failure> {
        weakCapture(other, at: \T.self)
    }
 }
