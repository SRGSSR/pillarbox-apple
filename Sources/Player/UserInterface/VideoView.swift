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
    @ObservedObject private var player: Player

    fileprivate var gravity: AVLayerVideoGravity = .resizeAspect
    fileprivate var isPictureInPictureSupported = false

    public var body: some View {
        switch player.mediaType {
        case .monoscopicVideo:
            MonoscopicVideoView(player: player, orientation: .monoscopicDefault)
        case .video:
            if isPictureInPictureSupported {
                PictureInPictureSupportingVideoView(player: player, gravity: gravity)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        PictureInPicture.shared.custom.stop()
                    }
            }
            else {
                BasicVideoView(player: player, gravity: gravity)
            }
        default:
            Color.clear
        }
    }

    /// Creates a view displaying video content.
    ///
    /// - Parameter player: The player whose content is displayed.
    public init(player: Player) {
        self.player = player
    }
}

public extension VideoView {
    /// Configures the mode used to display the content within the view frame.
    ///
    /// - Parameter gravity: The mode to use.
    ///
    /// This parameter is only applied if the content supports it (most notably video content).
    func gravity(_ gravity: AVLayerVideoGravity) -> VideoView {
        var view = self
        view.gravity = gravity
        return view
    }

    /// Configures Picture in Picture support for the video view.
    ///
    /// - Parameter isPictureInPictureSupported: A Boolean set to `true` if the view must be able to share its video 
    ///   layer for Picture in Picture.
    ///
    /// Enabling Picture in Picture support is required but not sufficient for Picture in Picture to be available.
    /// Other conditions have to be fulfilled (most notably the content must be a video).
    func supportsPictureInPicture(_ isPictureInPictureSupported: Bool = true) -> VideoView {
        var view = self
        view.isPictureInPictureSupported = isPictureInPictureSupported
        return view
    }
}
