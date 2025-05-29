//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Application {
    static let identifier = Bundle.main.bundleIdentifier
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
}
