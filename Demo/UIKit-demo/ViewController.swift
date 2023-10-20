//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

final class ViewController: UIViewController {
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        let button = UIButton()
        button.setTitle("Open player", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.addTarget(self, action: #selector(openPlayer(_:)), for: .touchUpInside)
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openPlayer(_ sender: Any) {
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        present(playerViewController, animated: true)
    }
}
