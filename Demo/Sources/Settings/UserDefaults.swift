//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Foundation
import Player

@objc
enum SeekBehaviorSetting: Int {
    case immediate
    case deferred
}

// Extensions allowing the use of KVO to detect user default changes by key.
// Keys and dynamic property names must match.
// 
// For more information see https://stackoverflow.com/a/47856467/760435
extension UserDefaults {
    static let presenterModeEnabledKey = "presenterModeEnabled"

#if os(iOS)
    static let playerLayoutKey = "playerLayout"
#endif

    static let allowsExternalPlaybackKey = "allowsExternalPlayback"
    static let smartNavigationEnabledKey = "smartNavigationEnabled"
    static let seekBehaviorSettingKey = "seekBehaviorSetting"
    static let serverSettingKey = "serverSetting"

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: Self.presenterModeEnabledKey)
    }

#if os(iOS)
    @objc dynamic var playerLayout: PlayerLayout {
        .init(rawValue: integer(forKey: Self.playerLayoutKey)) ?? .custom
    }
#endif

    @objc dynamic var allowsExternalPlaybackEnabled: Bool {
        bool(forKey: Self.allowsExternalPlaybackKey)
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
        .init(rawValue: integer(forKey: Self.serverSettingKey)) ?? .production
    }

    func registerDefaults() {
        register(defaults: [
            Self.presenterModeEnabledKey: false,
            Self.seekBehaviorSettingKey: SeekBehaviorSetting.immediate.rawValue,
            Self.allowsExternalPlaybackKey: true,
            Self.smartNavigationEnabledKey: true,
            Self.serverSettingKey: ServerSetting.production.rawValue
        ])
    }
}
