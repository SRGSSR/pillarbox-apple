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
    private let rowContent: (_ source: Any?, _ isCurrent: Bool) -> RowContent
    private let selection: Binding<PlayerItem?>?
    @State private var _selection: PlayerItem?

    public var body: some View {
        List($player.items, id: \.self, editActions: editActions, selection: selection ?? $_selection) { item in
            rowContent(item.wrappedValue.source, item.wrappedValue == player.currentItem)
        }
        .onChange(of: _selection) { selection in
            player.currentItem = selection
        }
    }

    /// Creates a playlist.
    ///
    /// - Parameters:
    ///   - player: The player whose items must be displayed.
    ///   - editActions: The available edit actions.
    ///   - selection: A binding to a selected value.
    ///   - rowContent: A view builder that creates a row for a single item of the playlist. The closure receives two
    ///     parameters:
    ///       - The ``PlayerItem/source`` associated with the item, if any.
    ///       - A Boolean indicating whether this source is associated with the current item.
    public init(
        player: Player,
        editActions: EditActions<[PlayerItem]> = [],
        selection: Binding<PlayerItem?>? = nil,
        @ViewBuilder rowContent: @escaping (_ source: Any?, _ isCurrent: Bool) -> RowContent
    ) {
        self.player = player
        self.editActions = editActions
        self.selection = selection
        self.rowContent = rowContent
    }
}
