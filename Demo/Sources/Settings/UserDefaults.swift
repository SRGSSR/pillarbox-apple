//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

@objc
enum SeekBehaviorSetting: Int {
    case immediate
    case deferred
}

enum PlaybackHudColor: Int {
    case yellow = 0
    case green = 1
    case red = 2
    case blue = 3
    case white = 4
}

// Extensions allowing the use of KVO to detect user default changes by key.
// Keys and dynamic property names must match.
// 
// For more information see https://stackoverflow.com/a/47856467/760435
extension UserDefaults {
    enum DemoSettingKey: String, CaseIterable {
        case presenterModeEnabled
        case smartNavigationEnabled
        case seekBehaviorSetting
        case serverSetting
    }

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: DemoSettingKey.presenterModeEnabled.rawValue)
    }

    @objc dynamic var smartNavigationEnabled: Bool {
        bool(forKey: DemoSettingKey.smartNavigationEnabled.rawValue)
    }

    var seekBehavior: SeekBehavior {
        switch seekBehaviorSetting {
        case .immediate:
            return .immediate
        case .deferred:
            return .deferred
        }
    }

    @objc dynamic var seekBehaviorSetting: SeekBehaviorSetting {
        .init(rawValue: integer(forKey: DemoSettingKey.seekBehaviorSetting.rawValue)) ?? .immediate
    }

    @objc dynamic var serverSetting: ServerSetting {
        .init(rawValue: integer(forKey: DemoSettingKey.serverSetting.rawValue)) ?? .ilProduction
    }

    private func registerDefaultDemoSettings() {
        register(defaults: [
            DemoSettingKey.presenterModeEnabled.rawValue: false,
            DemoSettingKey.seekBehaviorSetting.rawValue: SeekBehaviorSetting.immediate.rawValue,
            DemoSettingKey.smartNavigationEnabled.rawValue: true,
            DemoSettingKey.serverSetting.rawValue: ServerSetting.ilProduction.rawValue
        ])
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
    static let playbackHudFontSizes = constant(iOS: 8..<41, tvOS: 20..<61)

    static let playbackHudDefaultFontSize = constant(iOS: 18, tvOS: 40)

    static func resetPlaybackHudSettings() {
        guard let playbackHud else { return }
        PlaybackHudSettingKey.allCases.forEach { key in
            playbackHud.removeObject(forKey: key.rawValue)
        }
    }

    private func registerDefaultPlaybackHudSettings() {
        register(defaults: [
            PlaybackHudSettingKey.fontSize.rawValue: Self.playbackHudDefaultFontSize
        ])
    }
}

extension UserDefaults {
    func registerDefaults() {
        registerDefaultDemoSettings()
        registerDefaultPlaybackHudSettings()
    }
}
