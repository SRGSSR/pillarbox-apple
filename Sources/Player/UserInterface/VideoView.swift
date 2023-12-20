//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SceneKit
import SwiftUI

/// A view displaying video content provided by an associated player.
///
/// Behavior: h-exp, v-exp
public struct VideoView: View {
    @ObservedObject private var player: Player

    fileprivate var gravity: AVLayerVideoGravity = .resizeAspect
    fileprivate var isPictureInPictureSupported = false
    fileprivate var orientation: SCNQuaternion = .monoscopicDefault

    public var body: some View {
        switch player.mediaType {
        case .monoscopicVideo:
            MonoscopicVideoView(player: player, orientation: orientation)
        default:
            ZStack {
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
            .opacity(player.mediaType != .unknown ? 1 : 0)
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
    func supportsPictureInPicture(_ isPictureInPictureSupported: Bool = true) -> VideoView {
        var view = self
        view.isPictureInPictureSupported = isPictureInPictureSupported
        return view
    }

    /// Configures the orientation at which the content is seen.
    ///
    /// - Parameter orientation: The orientation.
    ///
    /// This parameter is only applied when monoscopic content is played. Use `.monoscopicDefault` to face the content
    /// without head-tilting.
    func orientation(_ orientation: SCNQuaternion) -> VideoView {
        var view = self
        view.orientation = orientation
        return view
    }
}
