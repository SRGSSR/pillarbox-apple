//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// A trigger is a device used to control a set of signal publishers. Signal publishers are publishers remotely
/// controlled by the trigger and which emit a void value when activated. Signal publishers never complete and thus
/// can be activated as many times as needed.
public struct Trigger {
    public typealias Index = Int
    public typealias Signal = AnyPublisher<Void, Never>
    
    private let sender = PassthroughSubject<Index, Never>()
    
    /// Create a trigger.
    public init() {}

    /// Create an associated signal activated by some integer index.
    /// - Parameter index: The index used for activation.
    /// - Returns: The signal.
    public func signal(activatedBy index: Index) -> Signal {
        return sender
            .filter { $0 == index }
            .map { _ in }
            .eraseToAnyPublisher()
    }

    /// Activate associated signal publishers matching the provided integer index, making them emit a single void value.
    /// - Parameter index: The index used for activation.
    public func activate(for index: Index) {
        sender.send(index)
    }
}

/**
 *  Extension for using hashable types as indices.
 */


public extension Trigger {
    /// Create an associated signal activated by some hashable value.
    /// - Parameter t: The hashable value used for activation.
    /// - Returns: The signal.
    func signal<T>(activatedBy t: T) -> Signal where T: Hashable {
        return signal(activatedBy: t.hashValue)
    }
    
    /// Activate associated signal publishers matching the provided hashable value, making them emit a single void value.
    /// - Parameter t: The hashable value used for activation.
    func activate<T>(for t: T) where T: Hashable {
        activate(for: t.hashValue)
    }
}
