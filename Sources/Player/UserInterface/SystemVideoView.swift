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

    fileprivate var gravity: AVLayerVideoGravity = .resizeAspect
    fileprivate var isPictureInPictureSupported = false

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
    /// - Parameter player: The player whose content is displayed.
    public init(player: Player) {
        self.player = player
    }
}

public extension SystemVideoView {
    /// Configures the mode used to display the content within the view frame.
    ///
    /// - Parameter gravity: The mode to use.
    ///
    /// This parameter is only applied if the content supports it (most notably video content).
    func gravity(_ gravity: AVLayerVideoGravity) -> SystemVideoView {
        var view = self
        view.gravity = gravity
        return view
    }

    /// Configures Picture in Picture support for the video view.
    ///
    /// - Parameter isPictureInPictureSupported: A Boolean set to `true` if the view must be able to share its video
    ///   layer for Picture in Picture.
    func supportsPictureInPicture(_ isPictureInPictureSupported: Bool = true) -> SystemVideoView {
        var view = self
        view.isPictureInPictureSupported = isPictureInPictureSupported
        return view
    }
}
