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

    private var gravity: AVLayerVideoGravity = .resizeAspect
    private var supportsPictureInPicture = false

    public var body: some View {
        ZStack {
            if supportsPictureInPicture {
                PictureInPictureSupportingSystemVideoView(player: player, gravity: gravity)
            }
            else {
                BasicSystemVideoView(player: player, gravity: gravity)
            }
        }
        .onAppear {
            PictureInPicture.shared.custom.detach(with: player.queuePlayer)
            PictureInPicture.shared.system.onAppear(
                with: player.queuePlayer,
                supportsPictureInPicture: supportsPictureInPicture
            )
        }
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
    /// - Parameter supportsPictureInPicture: A Boolean set to `true` if the view must be able to share its video
    ///   layer for Picture in Picture.
    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> SystemVideoView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}
