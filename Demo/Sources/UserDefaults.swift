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
    static let bodyCountersEnabledKey = "bodyCountersEnabled"
    static let seekBehaviorSettingKey = "seekBehaviorSetting"
    static let allowsExternalPlaybackSettingKey = "allowsExternalPlaybackSetting"
    static let audiovisualBackgroundPlaybackPolicySettingKey = "audiovisualBackgroundPlaybackPolicySetting"

    @objc dynamic var presenterModeEnabled: Bool {
        bool(forKey: Self.presenterModeEnabledKey)
    }

    @objc dynamic var bodyCountersEnabled: Bool {
        bool(forKey: Self.bodyCountersEnabledKey)
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

    @objc dynamic var allowsExternalPlaybackEnabled: Bool {
        bool(forKey: Self.allowsExternalPlaybackSettingKey)
    }

    @objc dynamic var audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy {
        .init(rawValue: integer(forKey: Self.audiovisualBackgroundPlaybackPolicySettingKey)) ?? .automatic
    }
}
