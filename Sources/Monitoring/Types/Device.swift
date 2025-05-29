//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit

enum Device {
    static let identifier = UIDevice.current.identifierForVendor?.uuidString.lowercased()

    static let model = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine.0) { pointer in
            String(cString: pointer)
        }
    }()

    static let type: DeviceType = {
        guard !ProcessInfo.processInfo.isRunningOnMac else { return .computer }
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .phone
        case .pad:
            return .tablet
        case .tv:
            return .tv
        case .vision:
            return .headset
        default:
            return .phone
        }
    }()
}
