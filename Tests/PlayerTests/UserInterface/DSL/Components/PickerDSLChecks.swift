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
        Picker(title: "", selection: .constant(true)) {}
        Picker(title: "", image: UIImage(), selection: .constant(true)) {}
        Picker(title: "", image: .checkmark, selection: .constant(true)) {}
        Picker(title: "", systemImage: "circle", selection: .constant(true)) {}
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Picker(title: "", selection: .constant(true)) {}
        Picker(title: "", image: UIImage(), selection: .constant(true)) {}
        Picker(title: "", image: .checkmark, selection: .constant(true)) {}
        Picker(title: "", systemImage: "circle", selection: .constant(true)) {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Picker(title: "", image: UIImage(), selection: .constant(true)) {}
        Picker(title: "", image: .checkmark, selection: .constant(true)) {}
        Picker(title: "", systemImage: "circle", selection: .constant(true)) {}
    }
}
