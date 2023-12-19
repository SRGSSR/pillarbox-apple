//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

/// A view providing the standard system playback user experience.
public struct SystemVideoView: View {
    private let player: Player
    private let gravity: AVLayerVideoGravity
    private let isPictureInPictureSupported: Bool

    public var body: some View {
        ZStack {
            if isPictureInPictureSupported {
                PictureInPictureSupportingSystemVideoView(player: player, gravity: gravity)
            }
            else {
                BasicSystemVideoView(player: player, gravity: gravity)
            }
        }
#if os(tvOS)
        .onDisappear {
            // Avoid sound continuing in background on tvOS, see https://github.com/SRGSSR/pillarbox-apple/issues/520
            if !PictureInPicture.shared.system.isActive {
                player.pause()
            }
        }
#endif
    }

    /// Creates a view displaying video content.
    ///
    /// - Parameters:
    ///   - player: The player whose content is displayed.
    ///   - gravity: The mode used to display the content within the view frame.
    ///   - isPictureInPictureSupported: A Boolean set to `true` if the view must be able to share its video layer for
    ///     Picture in Picture.
    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect, isPictureInPictureSupported: Bool = false) {
        self.player = player
        self.gravity = gravity
        self.isPictureInPictureSupported = isPictureInPictureSupported
    }
}
