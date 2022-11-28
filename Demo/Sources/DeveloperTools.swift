//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import SwiftUI

extension View {
    func debugBodyCounter(
        color: UIColor = .red
    ) -> some View {
        Group {
            if UserDefaults.standard.bodyCountersEnabled {
                _debugBodyCounter(color: color)
            }
            else {
                self
            }
        }
    }
}
