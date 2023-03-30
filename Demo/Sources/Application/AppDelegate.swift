//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import AVFoundation
import Combine
import Core
import ShowTime
import SRGDataProvider
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()

    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        UserDefaults.standard.registerDefaults()
        configureShowTime()
        configureDataProvider()
        configureAnalytics()
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

    private func configureDataProvider() {
        UserDefaults.standard.publisher(for: \.serviceUrl)
            .receiveOnMainThread()
            .sink { serviceUrl in
                SRGDataProvider.current = SRGDataProvider(serviceURL: serviceUrl.url)
            }
            .store(in: &cancellables)
    }

    private func configureAnalytics() {
        let configuration = Analytics.Configuration(
            vendor: .RTS,
            sourceKey: "11111111-1111-1111-1111-111111111111",
            site: "rts-app-test-v"
        )
        try? Analytics.shared.start(with: configuration)
    }
}
