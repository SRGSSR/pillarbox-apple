//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Core
import Player
import SwiftUI

#if os(iOS)

struct SettingsMenu: View {
    @ObservedObject var player: Player

    var body: some View {
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
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu(player: Player())
            .background(.black)
    }
}

#endif
