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

    private var gravity: AVLayerVideoGravity = .resizeAspect
    private var supportsPictureInPicture = false
    private var viewport: Viewport = .standard

    public var body: some View {
        ZStack {
            switch viewport {
            case .standard:
                ZStack {
                    if supportsPictureInPicture {
                        PictureInPictureSupportingVideoView(player: player, gravity: gravity)
                            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                                // When returning from basic Picture in Picture we must force a stop so that the PiP overlay
                                // is merged back into the player view.
                                PictureInPicture.shared.custom.stop()
                            }
                    }
                    else {
                        BasicVideoView(player: player, gravity: gravity)
                    }
                }
            case let .monoscopic(orientation):
                MonoscopicVideoView(player: player, orientation: orientation)
            }
        }
        .opacity(player.mediaType != .unknown ? 1 : 0)
        .onAppear {
            PictureInPicture.shared.system.detach(with: player.queuePlayer)
            PictureInPicture.shared.custom.onAppear(
                with: player.queuePlayer,
                supportsPictureInPicture: isPictureInPictureEffectivelySupported
            )
        }
    }

    private var isPictureInPictureEffectivelySupported: Bool {
        switch viewport {
        case .standard:
            return supportsPictureInPicture
        case .monoscopic:
            return false
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
    /// - Parameter supportsPictureInPicture: A Boolean set to `true` if the view must be able to share its video
    ///   layer for Picture in Picture.
    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> VideoView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }

    /// Configures the viewport of the video view.
    ///
    /// - Parameter viewport: The viewport.
    func viewport(_ viewport: Viewport) -> VideoView {
        var view = self
        view.viewport = viewport
        return view
    }
}
