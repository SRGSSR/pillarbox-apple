//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import SwiftUI

extension View {
    func debugBodyCounter(
        color: Color = .red,
        alignment: Alignment = .topTrailing,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) -> some View {
        Group {
            if UserDefaults.standard.bodyCountersEnabled {
                _debugBodyCounter(color: color, alignment: alignment, file: file, line: line, column: column)
            }
            else {
                self
            }
        }
    }
}
