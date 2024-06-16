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
    /// - Returns: A view that fills the given binding when the `publisher` emits an event.
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
}
