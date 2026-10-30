//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct StandardSystemVideoView<VideoOverlay>: UIViewControllerRepresentable where VideoOverlay: View {
    let player: Player
    let videoOverlay: VideoOverlay
    let gravity: AVLayerVideoGravity
    let supportsPictureInPicture: Bool

    let transportBarContent: TransportBarContent
    let contextualActionsContent: ContextualActionsContent
    let infoViewActionsContent: InfoViewActionsContent
    let infoViewTabsContent: InfoViewTabsContent

    static func dismantleUIViewController(_ uiViewController: PictureInPictureHostViewController, coordinator: Void) {
        PictureInPicture.shared.system.dismantleHostViewController(uiViewController)
    }

    func makeUIViewController(context: Context) -> PictureInPictureHostViewController {
        let controller = PictureInPicture.shared.system.makeHostViewController(for: player, supportsPictureInPicture: supportsPictureInPicture)
        if let playerViewController = controller.playerViewController {
            playerViewController.allowsPictureInPicturePlayback = supportsPictureInPicture
#if os(iOS)
            playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
#endif
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: PictureInPictureHostViewController, context: Context) {
        if let playerViewController = uiViewController.playerViewController {
            playerViewController.player = player.systemPlayer
            playerViewController.allowsPictureInPicturePlayback = supportsPictureInPicture
            playerViewController.videoGravity = gravity
            playerViewController.setVideoOverlay(videoOverlay)
            PictureInPicture.shared.system.updateHostViewController(uiViewController, supportsPictureInPicture: supportsPictureInPicture)
#if os(tvOS)
            playerViewController.updateTransportBarCustomMenuItemsIfNeeded(with: transportBarContent.toMenuElements())
            playerViewController.updateContextualActionsIfNeeded(with: contextualActionsContent.toActions())
            playerViewController.updateInfoViewActionsIfNeeded(with: infoViewActionsContent.toActions(dismissing: playerViewController))
            playerViewController.customInfoViewControllers = infoViewTabsContent.viewControllers(
                reusing: playerViewController.customInfoViewControllers,
                for: player
            )
#endif
        }
    }
}
