//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import SwiftUI

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension NotificationCenter {
    /// The usual notification publisher retains the filter object, potentially creating cycles. The following
    /// publisher avoids this issue while still only observing the filter object (if any), even after it is
    /// eventually deallocated.
    /// - Parameters:
    ///   - name: The notification to observe.
    ///   - object: The object to observe (weakly captured).
    /// - Returns: A notification publisher.
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
    /// - Parameters:
    ///   - other: The other object to weakly capture.
    ///   - keyPath: The key path for which to provide values.
    /// - Returns: A publisher combining the original output with properties from the weakly captured object.
    func weakCapture<T: AnyObject, V>(_ other: T?, at keyPath: KeyPath<T, V>) -> AnyPublisher<(Output, V), Failure> {
        compactMap { [weak other] output -> (Output, V)? in
            guard let other else { return nil }
            return (output, other[keyPath: keyPath])
        }
        .eraseToAnyPublisher()
    }

    /// Capture another object weakly and provide it as additional output. Does not emit when the object is `nil`.
    /// - Parameters:
    ///   - other: The other object to weakly capture.
    /// - Returns: A publisher combining the original output with the weakly captured object (if not `nil`).
    func weakCapture<T: AnyObject>(_ other: T?) -> AnyPublisher<(Output, T), Failure> {
        weakCapture(other, at: \T.self)
    }
 }

public extension Binding {
    /// Create a binding to an object property.
    /// - Parameters:
    ///   - object: The object to bind to.
    ///   - keyPath: The key path to bind to.
    init<T>(_ object: T, at keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }

    /// Create a binding to an object nullable property.
    /// - Parameters:
    ///   - object: The object to bind to.
    ///   - keyPath: The key path to bind to.
    ///   - defaultValue: The default value to use when the property is `nil`.
    init<T>(_ object: T, at keyPath: ReferenceWritableKeyPath<T, Value?>, defaultValue: Value) {
        self.init(
            get: { object[keyPath: keyPath] ?? defaultValue },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
