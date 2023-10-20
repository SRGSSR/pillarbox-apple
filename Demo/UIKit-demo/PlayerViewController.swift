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
    }
}
