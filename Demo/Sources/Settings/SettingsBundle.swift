//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

class SettingsBundle: ObservableObject {
    @Published private(set) var showsWebDemo = false

    init() {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in
                UserDefaults.standard.bool(forKey: "shows_web_demo")
            }
            .assign(to: &$showsWebDemo)
    }
}
