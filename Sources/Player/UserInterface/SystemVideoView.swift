//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

/// A view providing the standard system playback user experience.
///
/// ### Remark
///
/// A bug in AVKit currently makes `SystemVideoView` leak resources after having interacted with the playback
/// button on iOS 16. This issue has been reported to Apple as FB11934227.
public struct SystemVideoView: View {
    @ObservedObject private var player: Player

    public var body: some View {
        VideoPlayer(player: player.queuePlayer)
    }

    public init(player: Player) {
        self.player = player
    }
}
