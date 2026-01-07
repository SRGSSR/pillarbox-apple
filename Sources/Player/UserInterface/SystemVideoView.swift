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

    private var transportBarContent = TransportBarContent()
    private var contextualActionsContent = ContextualActionsContent()
    private var infoViewActionsContent = InfoViewActionsContent()
    private var customInfoViewsContent = InfoViewTabsContent()

    // swiftlint:disable:next missing_docs
    public var body: some View {
        ZStack {
            if supportsPictureInPicture {
                PictureInPictureSupportingSystemVideoView(
                    player: player,
                    videoOverlay: videoOverlay,
                    gravity: gravity,
                    transportBarContent: transportBarContent,
                    contextualActionsContent: contextualActionsContent,
                    infoViewActionsContent: infoViewActionsContent,
                    customInfoViewsContent: customInfoViewsContent
                )
            }
            else {
                BasicSystemVideoView(
                    player: player,
                    videoOverlay: videoOverlay,
                    gravity: gravity,
                    transportBarContent: transportBarContent,
                    contextualActionsContent: contextualActionsContent,
                    infoViewActionsContent: infoViewActionsContent,
                    customInfoViewsContent: customInfoViewsContent
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
}

@available(iOS, unavailable)
@available(tvOS 16, *)
public extension SystemVideoView {
    /// Items presented in the transport bar.
    ///
    /// - Parameter content: The content builder
    ///
    /// Use this modifier to configure menus and actions:
    ///
    /// ```swift
    /// SystemVideoView(player: player)
    ///    .transportBar {
    ///        Button("Favorite", systemImage: "heart") {
    ///            // ...
    ///        }
    ///        Picker"Quality", systemImage: "person.and.background.dotted", selection: $quality) {
    ///            Option("Low", value: .low)
    ///            Option("Medium", value: .medium)
    ///            Option("High", value: .high)
    ///        }
    ///    }
    /// ```
    ///
    /// Complex menu hierarchies can be created by nesting ``Menu``, ``Picker``, ``ÌnlinePicker`` and ``Section`` elements
    /// containing ``Button``s and ``Option``s. Some combinations are not permitted, so follow compilation error messages when
    /// constructing menus.
    ///
    /// > Important: One up to seven root items are supported.
    func transportBar(@TransportBarContentBuilder content: () -> TransportBarContent) -> SystemVideoView {
        var view = self
        view.transportBarContent = content()
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
    ///        Button("From Beginning", systemImage: "gobackward") {
    ///            player.skipToDefault()
    ///        }
    ///    }
    /// ```
    ///
    /// > Important: One up to seven actions are supported.
    @available(iOS, unavailable)
    @available(tvOS 16, *)
    func contextualActions(@ContextualActionsContentBuilder content: () -> ContextualActionsContent) -> SystemVideoView {
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
    ///        Button("From Beginning", systemImage: "gobackward") {
    ///            player.skipToDefault()
    ///        }
    ///    }
    /// ```
    ///
    /// > Important: One or two actions are supported.
    @available(iOS, unavailable)
    @available(tvOS 16, *)
    func infoViewActions(@InfoViewActionsContentBuilder content: () -> InfoViewActionsContent) -> SystemVideoView {
        var view = self
        view.infoViewActionsContent = content()
        return view
    }

    /// Custom info views displayed in the info tab.
    ///
    /// - Parameters:
    ///   - height: The height of the tallest content tab.
    ///   - content: A builder closure that provides one or more `Tab` instances.
    ///
    /// Use this modifier to configure actions:
    ///
    /// ```swift
    /// SystemVideoView(player: player)
    ///    .customInfoViews {
    ///        Tab("Cast") {
    ///             VStack {
    ///                Text("Actor 1")
    ///                Text("Actor 2")
    ///            }
    ///        }
    ///    }
    /// ```
    func customInfoViews(_ height: CGFloat = 350, @InfoViewTabsContentBuilder content: () -> InfoViewTabsContent) -> Self {
        var view = self
        view.customInfoViewsContent = .init(height: height, children: content().children)
        return view
    }
}
