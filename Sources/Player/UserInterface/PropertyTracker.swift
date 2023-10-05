//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import SwiftUI

/// An observable object which tracks player properties.
///
/// `Player` provides automatic observable updates for a subset of its `PlayerProperties`, but properties updated
/// at a higher rate should be observed locally to avoid triggering unnecessary refreshes in large views. Use
/// `PropertyTracker` to observe `PlayerProperties` that cannot automatically be observed directly from `Player`.
public final class PropertyTracker<T>: ObservableObject where T: Equatable {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// The value observed at the provided key path.
    @Published public private(set) var value: T

    /// Creates a property tracker.
    public init(at keyPath: KeyPath<PlayerProperties, T> = \.self) {
        value = PlayerProperties.empty[keyPath: keyPath]
        $player
            .map { player -> AnyPublisher<PlayerProperties, Never> in
                guard let player else { return Just(.empty).eraseToAnyPublisher() }
                return player.propertiesPublisher().eraseToAnyPublisher()
            }
            .switchToLatest()
            .slice(at: keyPath)
            .receiveOnMainThread()
            .assign(to: &$value)
    }
}

public extension View {
    /// Binds a property tracker to a player.
    ///
    /// - Parameters:
    ///   - propertyTracker: The property tracker to bind.
    ///   - player: The player to observe.
    func bind<T>(_ propertyTracker: PropertyTracker<T>, to player: Player?) -> some View where T: Equatable {
        onAppear {
            propertyTracker.player = player
        }
        .onChange(of: player) { newValue in
            propertyTracker.player = newValue
        }
    }
}
