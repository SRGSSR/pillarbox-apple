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
public struct SystemVideoView<VideoOverlay>: View where VideoOverlay: View {
    private var videoOverlay: VideoOverlay
    @ObservedObject private var player: Player

    public var body: some View {
        VideoPlayer(player: player.queuePlayer) {
            videoOverlay
        }
#if os(tvOS)
        .onDisappear {
            // Avoid sound continuing in background on tvOS, see https://github.com/SRGSSR/pillarbox-apple/issues/520.
            player.pause()
        }
#endif
    }

    /// Creates the view.
    ///
    /// - Parameters:
    ///   - player: The player whose contents will be rendered.
    ///   - videoOverlay: A closure returning an overlay view to be placed atop the player's content. This view is
    ///     fully interactive, but is placed below the system-provided playback controls and will only receive unhandled
    ///     events.
    public init(player: Player, @ViewBuilder videoOverlay: () -> VideoOverlay) {
        self.player = player
        self.videoOverlay = videoOverlay()
    }
}

public extension SystemVideoView where VideoOverlay == EmptyView {
    /// Creates the view.
    /// 
    /// - Parameters:
    ///   - player: The player whose contents will be rendered.
    init(player: Player) {
        self.init(player: player) {
            EmptyView()
        }
    }
}
