//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

private var kIdKey: Void?

/// An item to be inserted into the player.
public final class PlayerItem: Equatable {
    @Published private(set) var source: Source

    private let id = UUID()

    /// Create the item from an `Asset` publisher data source.
    public init<P>(publisher: P) where P: Publisher, P.Output == Asset {
        source = Source(id: id, asset: .loading)
        publisher
            .catch { error in
                Just(.failed(error: error))
            }
            .map { [id] asset in
                Source(id: id, asset: asset)
            }
            .assign(to: &$source)
    }

    /// Create a player item from a URL.
    /// - Parameters:
    ///   - url: The URL to play.
    ///   - configuration: A closure to configure player items created from the receiver.
    public convenience init(
        url: URL,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) {
        self.init(
            publisher: Just(
                .simple(url: url, configuration: configuration)
            )
        )
    }

    public static func == (lhs: PlayerItem, rhs: PlayerItem) -> Bool {
        lhs === rhs
    }

    static func playerItems(from items: [PlayerItem]) -> [AVPlayerItem] {
        Source.playerItems(from: items.map(\.source))
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        playerItem?.id == id
    }
}

extension PlayerItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(source)"
    }
}

extension AVPlayerItem {
    /// An identifier to identify player items delivered by the same data source.
    private(set) var id: UUID? {
        get {
            objc_getAssociatedObject(self, &kIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &kIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Assign an identifier to identify player items delivered by the same data source.
    /// - Parameter id: The id to assign.
    /// - Returns: The receiver with the id assigned to it.
    func withId(_ id: UUID) -> AVPlayerItem {
        self.id = id
        return self
    }
}
