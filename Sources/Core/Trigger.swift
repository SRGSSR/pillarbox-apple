//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

/// A device used to control a set of other publishers.
///
/// A trigger is a small device from which other publishers, called signal publishers, can be created. These publishers
/// can be activated at any time by the trigger.
public struct Trigger: @unchecked Sendable {
    /// The index type.
    public typealias Index = Int

    /// The signal type.
    public typealias Signal = AnyPublisher<Void, Never>

    private let sender = PassthroughSubject<Index, Never>()
    private let lock = NSRecursiveLock()

    /// Creates a trigger.
    public init() {}

    /// Creates an associated signal activated by some integer index.
    ///
    /// - Parameter index: The index used for activation.
    /// - Returns: The signal.
    public func signal(activatedBy index: Index) -> Signal {
        withLock(lock) {
            sender
                .filter { $0 == index }
                .map { _ in }
                .eraseToAnyPublisher()
        }
    }

    /// Activates associated signal publishers matching the provided integer index.
    ///
    /// - Parameter index: The index used for activation.
    ///
    /// Signal publishers emit a single void value upon activation.
    public func activate(for index: Index) {
        withLock(lock) {
            sender.send(index)
        }
    }
}

public extension Trigger {
    /// Creates an associated signal activated by some hashable value.
    ///
    /// - Parameter t: The hashable value used for activation.
    /// - Returns: The signal.
    func signal<T>(activatedBy t: T) -> Signal where T: Hashable {
        signal(activatedBy: t.hashValue)
    }

    /// Activates associated signal publishers matching the provided hashable value.
    ///
    /// - Parameter t: The hashable value used for activation.
    ///
    /// Signal publishers emit a single void value upon activation.
    func activate<T>(for t: T) where T: Hashable {
        activate(for: t.hashValue)
    }
}
