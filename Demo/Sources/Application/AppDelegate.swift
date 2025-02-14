//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFAudio
import Combine
import os
import PillarboxAnalytics
import ShowTime
import SRGDataProvider
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private static let logger = Logger(category: "AppDelegate")
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
            sourceKey: .development,
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
        Self.logger.debug("[didTrackPageView] commandersAct: \(commandersActPageView.name)")
    }

    func didSendEvent(commandersAct commandersActEvent: CommandersActEvent) {
        Self.logger.debug("[didSendEvent] commandersAct: \(commandersActEvent.name)")
    }
}
