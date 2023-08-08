//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A standard settings menu mimicking Apple player menu.
@available(iOS 16.0, tvOS 17.0, *)
public struct SettingsMenu: View {
    @ObservedObject private var player: Player

    public var body: some View {
        Menu {
            MediaSelectionMenu(characteristic: .legible, player: player)
            MediaSelectionMenu(characteristic: .audible, player: player)
            PlaybackSpeedMenu(speeds: [0.5, 1, 1.25, 1.5, 2], player: player)
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .tint(.white)
                .aspectRatio(contentMode: .fit)
        }
    }
    
    /// Creates a settings menu.
    ///
    /// - Parameter player: The player which settings must be displayed for.
    public init(player: Player) {
        self.player = player
    }
}

@available(iOS 16.0, tvOS 17.0, *)
struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu(player: Player())
            .background(.black)
    }
}
