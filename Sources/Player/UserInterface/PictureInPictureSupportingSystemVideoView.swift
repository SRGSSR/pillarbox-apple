//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView: UIViewControllerRepresentable {
#if os(tvOS)
    typealias Coordinator = AVPlayerViewControllerSpeedCoordinator
#else
    typealias Coordinator = Void
#endif

    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]
    let overlayViewController: UIViewController

    static func dismantleUIViewController(_ uiViewController: PictureInPictureHostViewController, coordinator: Coordinator) {
        PictureInPicture.shared.system.dismantleHostViewController(uiViewController)
    }

#if os(tvOS)
    func makeCoordinator() -> Coordinator {
        .init()
    }
#endif

    func makeUIViewController(context: Context) -> PictureInPictureHostViewController {
        PictureInPicture.shared.system.makeHostViewController(for: player)
    }

    func updateUIViewController(_ uiViewController: PictureInPictureHostViewController, context: Context) {
        uiViewController.viewController?.player = player.systemPlayer
        uiViewController.viewController?.videoGravity = gravity
        uiViewController.viewController?.addOverlayViewController(overlayViewController)
#if os(tvOS)
        uiViewController.viewController?.contextualActions = contextualActions
        context.coordinator.player = player
        context.coordinator.controller = uiViewController.viewController
#endif
    }
}
