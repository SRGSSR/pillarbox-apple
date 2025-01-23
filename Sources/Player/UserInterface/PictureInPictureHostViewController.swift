//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import UIKit

final class PictureInPictureHostViewController: UIViewController {
    weak var playerViewController: AVPlayerViewController?

    func addViewController(_ playerViewController: AVPlayerViewController) {
        addChild(playerViewController)
        view.addSubview(playerViewController.view)

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        playerViewController.didMove(toParent: self)
        self.playerViewController = playerViewController
    }
}
