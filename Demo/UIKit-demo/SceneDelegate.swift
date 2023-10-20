//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window

        PictureInPicture.shared.delegate = self
    }
}

extension SceneDelegate: PictureInPictureDelegate {
    func willStartPictureInPicture() {
        window?.rootViewController?.dismiss(animated: true)
    }
    
    func didStartPictureInPicture() {}
    
    func restoreUserInterfaceForPictureInPictureStop(with completionHandler: @escaping (Bool) -> Void) {
        window?.rootViewController?.present(PlayerViewController(), animated: true) {
            completionHandler(true)
        }
    }
    
    func willStopPictureInPicture() {}
    
    func didStopPictureInPicture() {}
}
