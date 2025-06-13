//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Dispatch

public extension ObservableObject {
    /// Creates a publisher providing the value of an observable object at the specified key path each time the
    /// object changes.
    ///
    /// - Parameter keyPath: The key path to observe.
    /// - Returns: A publisher emitting values for the observed key path each time the receiver changes.
    ///
    /// This publisher makes it possible to generate an update stream for non-published properties of an observable
    /// object.
    ///
    /// Note that the current value is automatically emitted upon subscription.
    func changePublisher<Output>(at keyPath: KeyPath<Self, Output>) -> AnyPublisher<Output, Never> {
        objectWillChange
            .receive(on: DispatchQueue.main)        // Simulates `objectDidChange` to ensure the object is up to date
            .map { _ in () }
            .prepend(())
            .compactMap { [weak self] in
                self?[keyPath: keyPath]
            }
            .eraseToAnyPublisher()
    }
}
