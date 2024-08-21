//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view displaying the items of a player as a playlist.
///
/// Rows display ``PlayerItem/source`` that must be cast to the proper type. Customization is performed using `List`
/// APIs.
public struct Playlist<T, RowContent>: View where RowContent: View {
    @ObservedObject private var player: Player
    private let type: T.Type
    private let editActions: EditActions<[PlayerItem]>
    private let rowContent: (T) -> RowContent

    public var body: some View {
        List($player.items, id: \.self, editActions: editActions, selection: $player.currentItem) { item in
            if let source = item.wrappedValue.source as? T {
                rowContent(source)
            }
            else {
                Color.clear
            }
        }
    }

    /// Creates a playlist.
    ///
    /// - Parameters:
    ///   - player: The player whose items must be displayed.
    ///   - type: The type to cast the ``PlayerItem/source`` to.
    ///   - editActions: The available edit actions.
    ///   - rowContent: A view builder that creates the view for a single row of the list.
    public init(player: Player, type: T.Type, editActions: EditActions<[PlayerItem]>, @ViewBuilder rowContent: @escaping (T) -> RowContent) {
        self.player = player
        self.type = type
        self.editActions = editActions
        self.rowContent = rowContent
    }
}
