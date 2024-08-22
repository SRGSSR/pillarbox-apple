//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A `List` to display and edit the items associated with a player.
///
/// `List` APIs can be used to customize the list appearance and behavior.
public struct Playlist<RowContent>: View where RowContent: View {
    @ObservedObject private var player: Player

    private let editActions: EditActions<[PlayerItem]>
    private let rowContent: (Any?) -> RowContent

    public var body: some View {
        List($player.items, id: \.self, editActions: editActions, selection: $player.currentItem) { item in
            rowContent(item.wrappedValue.source)
        }
    }

    /// Creates a playlist.
    ///
    /// - Parameters:
    ///   - player: The player whose items must be displayed.
    ///   - editActions: The available edit actions.
    ///   - rowContent: A view builder that creates the view for a single row of the playlist. The source associated
    ///     with a ``PlayerItem``, if any, is provided as parameter to the closure.
    public init(player: Player, editActions: EditActions<[PlayerItem]>, @ViewBuilder rowContent: @escaping (Any?) -> RowContent) {
        self.player = player
        self.editActions = editActions
        self.rowContent = rowContent
    }
}
