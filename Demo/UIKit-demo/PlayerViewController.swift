//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Player
import SwiftUI
import UIKit

final class PlayerViewController: UIViewController {
    private static let player = Player(item: .urn("urn:rts:video:14386873"))

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        let hostingController = UIHostingController(rootView: PlaybackView(player: Self.player, supportsPictureInPicture: true))
        addChild(hostingController)

        let hostView = hostingController.view!
        view.addSubview(hostView)

        hostView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        view.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !PictureInPicture.shared.isActive {
            // Could also reset but requires the ability to load the content again.
            Self.player.pause()
        }
    }

    @objc private func close(_ sender: Any) {
        dismiss(animated: true)
    }
}
