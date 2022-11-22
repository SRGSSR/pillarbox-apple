//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import ShowTime
import UIKit

// MARK: Application delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()

    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        configureShowTime()
        return true
    }

    private func configureShowTime() {
        UserDefaults.standard.publisher(for: \.presenterModeEnabled)
            .receiveOnMainThread()
            .sink { isEnabled in
                ShowTime.enabled = isEnabled ? .always : .never
            }
            .store(in: &cancellables)
    }
}
