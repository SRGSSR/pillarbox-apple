//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SwiftUI

public extension View {
    /// Assigns values emitted by the given publisher at the specified key path to a binding.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - keyPath: The key path to extract.
    ///   - binding: The binding to which values must be assigned.
    func onReceive<P, T>(
        _ publisher: P,
        assign keyPath: KeyPath<P.Output, T>,
        to binding: Binding<T>
    ) -> some View where P: Publisher, P.Failure == Never, T: Equatable {
        onReceive(publisher.slice(at: keyPath).receiveOnMainThread()) { output in
            if binding.wrappedValue != output {
                binding.wrappedValue = output
            }
        }
    }

    /// Observes values emitted by the given publisher at the specified key path.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to subscribe to.
    ///   - keyPath: The key path to extract.
    ///   - action: A closure to run when the value changes, executed on the main thread. The action is not called for
    ///     the first value that the publisher might provide upon subscription.
    func onReceive<P, T>(
        _ publisher: P,
        at keyPath: KeyPath<P.Output, T>,
        perform action: @escaping (T) -> Void
    ) -> some View where P: Publisher, P.Failure == Never, T: Equatable {
        onReceive(publisher.slice(at: keyPath).dropFirst().receiveOnMainThread(), perform: action)
    }
}
