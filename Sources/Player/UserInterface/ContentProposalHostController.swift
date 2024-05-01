//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

final class ContentProposalHostController<Content>: AVContentProposalViewController where Content: View {
    private let playerViewFrame: CGRect?
    private let content: Content

    override var preferredPlayerViewFrame: CGRect {
        playerViewFrame ?? super.preferredPlayerViewFrame
    }

    init(playerViewFrame: CGRect?, content: Content) {
        self.playerViewFrame = playerViewFrame
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let view = UIView()

        let hostController = UIHostingController(rootView: content)
        addChild(hostController)

        if let hostView = hostController.view {
            view.addSubview(hostView)

            hostView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostView.topAnchor.constraint(equalTo: view.topAnchor),
                hostView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        hostController.didMove(toParent: self)

        self.view = view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
