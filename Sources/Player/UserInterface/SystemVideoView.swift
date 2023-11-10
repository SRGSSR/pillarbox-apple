//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

private class PlayerViewController: AVPlayerViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMovingToParent || isBeingPresented {
            PictureInPicture.shared.system.stop()
        }
    }
}

private struct _SystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
    }
}

// swiftlint:disable:next type_name
private struct _PictureInPictureSupportingSystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = PictureInPicture.shared.system.playerViewController ?? PlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        PictureInPicture.shared.system.acquire(for: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        PictureInPicture.shared.system.update(with: player.queuePlayer)
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
    }
}

/// A view providing the standard system playback user experience.
public struct SystemVideoView: View {
    private let player: Player
    private let gravity: AVLayerVideoGravity
    private let isPictureInPictureSupported: Bool

    public var body: some View {
        ZStack {
            if isPictureInPictureSupported {
                _PictureInPictureSupportingSystemVideoView(player: player, gravity: gravity)
            }
            else {
                _SystemVideoView(player: player, gravity: gravity)
            }
        }
#if os(tvOS)
        .onDisappear {
            // Avoid sound continuing in background on tvOS, see https://github.com/SRGSSR/pillarbox-apple/issues/520
            if !PictureInPicture.shared.isActive {
                player.pause()
            }
        }
#endif
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
