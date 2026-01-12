//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView<VideoOverlay>: UIViewControllerRepresentable where VideoOverlay: View {
    let player: Player
    let videoOverlay: VideoOverlay
    let gravity: AVLayerVideoGravity

    let transportBarContent: TransportBarContent
    let contextualActionsContent: ContextualActionsContent
    let infoViewActionsContent: InfoViewActionsContent
    let infoViewTabsContent: InfoViewTabsContent

    static func dismantleUIViewController(_ uiViewController: PictureInPictureHostViewController, coordinator: Void) {
        PictureInPicture.shared.system.dismantleHostViewController(uiViewController)
    }

    func makeUIViewController(context: Context) -> PictureInPictureHostViewController {
        PictureInPicture.shared.system.makeHostViewController(for: player)
    }

    func updateUIViewController(_ uiViewController: PictureInPictureHostViewController, context: Context) {
        if let playerViewController = uiViewController.playerViewController {
            playerViewController.player = player.systemPlayer
            playerViewController.videoGravity = gravity
            playerViewController.setVideoOverlay(videoOverlay)
#if os(tvOS)
            playerViewController.updateTransportBarCustomMenuItemsIfNeeded(with: transportBarContent.toMenuElements())
            playerViewController.updateContextualActionsIfNeeded(with: contextualActionsContent.toActions())
            playerViewController.updateInfoViewActionsIfNeeded(with: infoViewActionsContent.toActions(dismissing: playerViewController))
            playerViewController.customInfoViewControllers = infoViewTabsContent.viewControllers(reusing: playerViewController.customInfoViewControllers)
#endif
        }
    }
}
