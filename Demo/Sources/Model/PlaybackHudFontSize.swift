//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit

enum PlaybackHudFontSize: Int, CaseIterable {
    case small
    case `default`
    case large

    private static let smallValue = constant(iOS: 9, tvOS: 30)
    private static let defaultValue = constant(iOS: 18, tvOS: 40)
    private static let largeValue = constant(iOS: 27, tvOS: 50)

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
