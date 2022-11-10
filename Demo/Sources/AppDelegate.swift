//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import UIKit

// MARK: Application delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    // swiftlint:disable discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        return true
    }
    // swiftlint:enable discouraged_optional_collection
}
