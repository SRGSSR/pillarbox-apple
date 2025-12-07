//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum SectionDSLChecks {
    @MenuContentBuilder
    static func menu() -> MenuContent {
        Section {}
        Section("") {}
    }

    @PickerContentBuilder<Void>
    static func picker() -> PickerContent<Void> {
        Section {}
        Section("") {}
    }
}
