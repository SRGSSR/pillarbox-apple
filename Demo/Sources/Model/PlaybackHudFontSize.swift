//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit

enum PlaybackHudFontSize: Int, CaseIterable {
    private static let smallValue = 9
    private static let defaultValue = 18
    private static let largeValue = 27

    case small
    case `default`
    case large

    var name: String {
        switch self {
        case .small:
            return "Small"
        case .default:
            return "Default"
        case .large:
            return "Large"
        }
    }

    var rawValue: Int {
        let value = Self.value(from: self)
        return Self.scaledValue(fromValue: value)
    }

    init?(rawValue: Int) {
        let value = Self.value(fromScaledValue: rawValue)
        self = Self.size(fromValue: value)
    }

    private static func value(from size: Self) -> Int {
        switch size {
        case .small:
            return smallValue
        case .default:
            return defaultValue
        case .large:
            return largeValue
        }
    }

    private static func size(fromValue value: Int) -> Self {
        switch value {
        case smallValue:
            return .small
        case largeValue:
            return .large
        default:
            return .default
        }
    }

    private static func scaledValue(fromValue value: Int) -> Int {
#if targetEnvironment(simulator)
        value
#else
        value * Int(UIScreen.main.scale)
#endif
    }

    private static func value(fromScaledValue value: Int) -> Int {
#if targetEnvironment(simulator)
        value
#else
        value / Int(UIScreen.main.scale)
#endif
    }
}
