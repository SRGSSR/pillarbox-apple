//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct BasicSystemVideoView<VideoOverlay>: UIViewControllerRepresentable where VideoOverlay: View {
    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]
    let infoViewActions: InfoViewActions
    let videoOverlay: VideoOverlay

    func makeCoordinator() -> SystemVideoViewCoordinator {
        .init()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = false
#if os(iOS)
        controller.updatesNowPlayingInfoCenter = false
#endif
        context.coordinator.controller = controller
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
        uiViewController.setVideoOverlay(videoOverlay)
#if os(tvOS)
        uiViewController.contextualActions = contextualActions
        configureInfoViewActions(for: uiViewController)
#endif
        context.coordinator.player = player
    }

    @available(iOS, unavailable)
    @available(tvOS 16, *)
    private func configureInfoViewActions(for uiViewController: AVPlayerViewController) {
        switch infoViewActions {
        case .system:
            return
        case .empty:
            uiViewController.infoViewActions = []
        case let .first(action):
            uiViewController.infoViewActions = [UIAction.from(action)]
        case let .last(action):
            uiViewController.infoViewActions.append(UIAction.from(action))
        case let .pair(firstAction, lastAction):
            uiViewController.infoViewActions = [firstAction, lastAction].map(UIAction.from)
        }
    }
}
