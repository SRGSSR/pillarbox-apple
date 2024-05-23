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
    static let presenterModeEnabledKey = "presenterModeEnabled"
    static let smartNavigationEnabledKey = "smartNavigationEnabled"
    static let seekBehaviorSettingKey = "seekBehaviorSetting"
    static let serverSettingKey = "serverSetting"

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: Self.presenterModeEnabledKey)
    }

    @objc dynamic var smartNavigationEnabled: Bool {
        bool(forKey: Self.smartNavigationEnabledKey)
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
        .init(rawValue: integer(forKey: Self.seekBehaviorSettingKey)) ?? .immediate
    }

    @objc dynamic var serverSetting: ServerSetting {
        .init(rawValue: integer(forKey: Self.serverSettingKey)) ?? .ilProduction
    }

    func registerDefaults() {
        register(defaults: [
            Self.presenterModeEnabledKey: false,
            Self.seekBehaviorSettingKey: SeekBehaviorSetting.immediate.rawValue,
            Self.smartNavigationEnabledKey: true,
            Self.serverSettingKey: ServerSetting.ilProduction.rawValue
        ])
    }
}

extension UserDefaults {
    static let playbackHud = UserDefaults(suiteName: "com.apple.avfoundation.videoperformancehud")

    enum playbackHudKey {
        static let enabled = "enable"                 // Bool
        static let color = "color"                    // Int, see `PlaybackHudColor`.
        static let fontSize = "fontsize"              // Int >= 8
        static let xOffset = "xoffset"                // Int >= 1
        static let yOffset = "yoffset"                // Int >= 1
    }
}
