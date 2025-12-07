//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum PickerDSLChecks {
    @MenuContentBuilder
    static func menu() -> MenuContent {
        Picker("", selection: .constant(true)) {}
        Picker("", image: UIImage(), selection: .constant(true)) {}
        Picker("", image: .checkmark, selection: .constant(true)) {}
        Picker("", systemImage: "circle", selection: .constant(true)) {}
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Picker("", selection: .constant(true)) {}
        Picker("", image: UIImage(), selection: .constant(true)) {}
        Picker("", image: .checkmark, selection: .constant(true)) {}
        Picker("", systemImage: "circle", selection: .constant(true)) {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Picker("", image: UIImage(), selection: .constant(true)) {}
        Picker("", image: .checkmark, selection: .constant(true)) {}
        Picker("", systemImage: "circle", selection: .constant(true)) {}
    }
}
