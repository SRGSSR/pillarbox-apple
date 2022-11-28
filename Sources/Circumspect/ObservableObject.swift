//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public extension ObservableObject {
    /// Create a publisher providing the value of an observable object at the specified key path each time the
    /// object changes. Makes it possible to create a publisher also for non-published properties of an observable
    /// object. Emits the current value upon subscription.
    /// - Parameter keyPath: The key path to observe.
    /// - Returns: A publisher emitting values for the observed key path each time the receiver changes.
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
