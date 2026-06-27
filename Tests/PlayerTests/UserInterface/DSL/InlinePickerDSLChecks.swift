//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum InlinePickerDSLChecks {
    @MenuContentBuilder
    static func menu() -> MenuContent {
        InlinePicker(selection: .constant(true)) {}
        InlinePicker("", selection: .constant(true)) {}
    }
}
