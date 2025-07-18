//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

// Extensions allowing the use of KVO to detect user default changes by key.
// Keys and dynamic property names must match.
//
// For more information see https://stackoverflow.com/a/47856467/760435
extension UserDefaults {
    enum DemoSettingKey: String, CaseIterable {
        case presenterModeEnabled
        case smartNavigationEnabled
        case seekBehaviorSetting
        case backwardSkipInterval
        case forwardSkipInterval
        case serverSetting
        case qualitySetting
    }

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: DemoSettingKey.presenterModeEnabled.rawValue)
    }

    @objc dynamic var smartNavigationEnabled: Bool {
        bool(forKey: DemoSettingKey.smartNavigationEnabled.rawValue)
    }

    var seekBehavior: SeekBehavior {
        switch seekBehaviorSetting {
        case .optimal:
            return .optimal
        case .deferred:
            return .deferred
        }
    }

    @objc dynamic var seekBehaviorSetting: SeekBehaviorSetting {
        .init(rawValue: integer(forKey: DemoSettingKey.seekBehaviorSetting.rawValue)) ?? .optimal
    }

    @objc dynamic var backwardSkipInterval: TimeInterval {
        double(forKey: DemoSettingKey.backwardSkipInterval.rawValue)
    }

    @objc dynamic var forwardSkipInterval: TimeInterval {
        double(forKey: DemoSettingKey.forwardSkipInterval.rawValue)
    }

    @objc dynamic var serverSetting: ServerSetting {
        .init(rawValue: integer(forKey: DemoSettingKey.serverSetting.rawValue)) ?? .production
    }

    @objc dynamic var qualitySetting: QualitySetting {
        .init(rawValue: integer(forKey: DemoSettingKey.qualitySetting.rawValue)) ?? .high
    }

    private static func registerDefaultDemoSettings() {
        UserDefaults.standard.register(defaults: [
            DemoSettingKey.presenterModeEnabled.rawValue: false,
            DemoSettingKey.smartNavigationEnabled.rawValue: true,
            DemoSettingKey.seekBehaviorSetting.rawValue: SeekBehaviorSetting.optimal.rawValue,
            DemoSettingKey.backwardSkipInterval.rawValue: 10,
            DemoSettingKey.forwardSkipInterval.rawValue: 10,
            DemoSettingKey.serverSetting.rawValue: ServerSetting.production.rawValue,
            DemoSettingKey.qualitySetting.rawValue: QualitySetting.high.rawValue
        ])
    }

    func limitsPublisher() -> AnyPublisher<PlayerLimits, Never> {
        publisher(for: \.qualitySetting)
            .map(\.limits)
            .eraseToAnyPublisher()
    }
}

extension UserDefaults {
    enum PlaybackHudSettingKey: String, CaseIterable {
        case enabled = "enable"                 // Bool
        case color                              // Int, see `PlaybackHudColor`.
        case fontSize = "fontsize"              // Int >= 8
        case xOffset = "xoffset"                // Int >= 1
        case yOffset = "yoffset"                // Int >= 1
    }

    static let playbackHud = UserDefaults(suiteName: "com.apple.avfoundation.videoperformancehud")

    static let playbackHudDefaultHudXOffset = 20
    static let playbackHudDefaultHudYOffset = 20

    static func resetPlaybackHudSettings() {
        guard let playbackHud else { return }
        PlaybackHudSettingKey.allCases.forEach { key in
            playbackHud.removeObject(forKey: key.rawValue)
        }
    }

    private static func registerDefaultPlaybackHudSettings() {
        playbackHud?.register(defaults: [
            PlaybackHudSettingKey.fontSize.rawValue: PlaybackHudFontSize.default.rawValue,
            PlaybackHudSettingKey.xOffset.rawValue: Self.playbackHudDefaultHudXOffset,
            PlaybackHudSettingKey.yOffset.rawValue: Self.playbackHudDefaultHudYOffset
        ])
    }
}

extension UserDefaults {
    static func registerDefaults() {
        registerDefaultDemoSettings()
        registerDefaultPlaybackHudSettings()
    }
}
