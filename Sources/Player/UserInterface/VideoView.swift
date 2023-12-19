//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

/// A view displaying video content provided by an associated player.
///
/// Behavior: h-exp, v-exp
public struct VideoView: View {
    private let player: Player
    private let gravity: AVLayerVideoGravity
    private let isPictureInPictureSupported: Bool

    public var body: some View {
        if isPictureInPictureSupported {
            PictureInPictureSupportingVideoView(player: player, gravity: gravity)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    PictureInPicture.shared.custom.stop()
                }
        }
        else {
            BasicVideoView(player: player, gravity: gravity)
        }
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
