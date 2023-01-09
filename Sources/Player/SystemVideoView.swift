//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

/// A video view with standard system user experience.
public struct SystemVideoView: View {
    @ObservedObject private var player: Player

    public var body: some View {
        VideoPlayer(player: player.rawPlayer)
    }

    public init(player: Player) {
        self.player = player
    }
}
