//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class SettingsBundle: ObservableObject {
    @Published private(set) var showsHiddenFeatures = false

    init() {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in
                UserDefaults.standard.bool(forKey: "hidden_features")
            }
            .assign(to: &$showsHiddenFeatures)
    }
}
