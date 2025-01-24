//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFAudio
import Combine
import PillarboxAnalytics
import ShowTime
import SRGDataProvider
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()

    // swiftlint:disable:next discouraged_optional_collection
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        UserDefaults.registerDefaults()
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
        UserDefaults.standard.publisher(for: \.serverSetting)
            .receiveOnMainThread()
            .sink { serverSetting in
                SRGDataProvider.current = serverSetting.dataProvider
            }
            .store(in: &cancellables)
    }

    private func configureAnalytics() {
        let configuration = Analytics.Configuration(
            vendor: .SRG,
            sourceKey: .developmentSourceKey,
            appSiteName: "pillarbox-demo-apple"
        )
        try? Analytics.shared.start(with: configuration, dataSource: self, delegate: self)
    }
}

extension AppDelegate: AnalyticsDataSource {
    var comScoreGlobals: ComScoreGlobals {
        .init(consent: .unknown, labels: [
           "demo_key": "demo_value"
        ])
    }

    var commandersActGlobals: CommandersActGlobals {
        .init(consentServices: ["service1", "service2", "service3"], labels: [
            "demo_key": "demo_value"
        ])
    }
}

extension AppDelegate: AnalyticsDelegate {
    func didTrackPageView(commandersAct commandersActPageView: CommandersActPageView) {
        // TODO: Should we expose the name or even all properties publicly?
        let name = Mirror(reflecting: commandersActPageView)
            .children
            .first { $0.label == "name" }?
            .value
        print("[didTrackPageView] commandersActPageView: \(String(describing: name))")
    }
}
