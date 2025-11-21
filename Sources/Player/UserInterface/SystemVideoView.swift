//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

/// A view providing the standard system playback user experience.
public struct SystemVideoView<VideoOverlay>: View where VideoOverlay: View {
    private let player: Player
    private let videoOverlay: VideoOverlay

    private var gravity: AVLayerVideoGravity = .resizeAspect
    private var supportsPictureInPicture = false

    private var contextualActionsContent: SystemVideoViewActionsContent = .empty
    private var infoViewActionsContent: SystemVideoViewActionsContent = .empty

    // swiftlint:disable:next missing_docs
    public var body: some View {
        ZStack {
            if supportsPictureInPicture {
                PictureInPictureSupportingSystemVideoView(
                    player: player,
                    gravity: gravity,
                    contextualActionsContent: contextualActionsContent,
                    infoViewActionsContent: infoViewActionsContent,
                    videoOverlay: videoOverlay
                )
            }
            else {
                BasicSystemVideoView(
                    player: player,
                    gravity: gravity,
                    contextualActionsContent: contextualActionsContent,
                    infoViewActionsContent: infoViewActionsContent,
                    videoOverlay: videoOverlay
                )
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
    /// - Parameters:
    ///    - player: The player whose content is displayed.
    ///    - videoOverlay: A closure returning an overlay view to be placed atop the player's content. This view is
    ///      fully interactive, but is placed below the system-provided playback controls and will only receive unhandled
    ///      events.
    public init(player: Player, @ViewBuilder videoOverlay: () -> VideoOverlay) {
        self.player = player
        self.videoOverlay = videoOverlay()
    }
}

public extension SystemVideoView where VideoOverlay == EmptyView {
    /// Creates a view displaying video content.
    ///
    /// - Parameter player: The player whose content is displayed.
    init(player: Player) {
        self.init(player: player) {
            EmptyView()
        }
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

    /// Actions presented contextually during playback.
    ///
    /// - Parameter content: The content builder
    ///
    /// Use this modifier to configure actions:
    ///
    /// ```swift
    /// SystemVideoView(player: player)
    ///    .contextualActions {
    ///        SystemVideoViewAction(title: "From Beginning", systemImage: "gobackward") {
    ///            player.skipToDefault()
    ///        }
    ///    }
    /// ```
    ///
    /// > Important: One up to seven actions are supported.
    @available(iOS, unavailable)
    @available(tvOS 16, *)
    func contextualActions(@SystemVideoViewActionsContentBuilder7 content: () -> SystemVideoViewActionsContent) -> SystemVideoView {
        var view = self
        view.contextualActionsContent = content()
        return view
    }

    /// Actions displayed in the info tab.
    ///
    /// - Parameter content: The content builder
    ///
    /// Use this modifier to configure actions:
    ///
    /// ```swift
    /// SystemVideoView(player: player)
    ///    .infoViewActions {
    ///        SystemVideoViewAction(title: "From Beginning", systemImage: "gobackward") {
    ///            player.skipToDefault()
    ///        }
    ///    }
    /// ```
    ///
    /// > Important: One or two actions are supported.
    @available(iOS, unavailable)
    @available(tvOS 16, *)
    func infoViewActions(@SystemVideoViewActionsContentBuilder2 content: () -> SystemVideoViewActionsContent) -> SystemVideoView {
        var view = self
        view.infoViewActionsContent = content()
        return view
    }
}
