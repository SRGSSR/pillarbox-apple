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
