//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum ToggleDSLChecks {
    @MenuContentBuilder
    static func menu() -> MenuContent {
        Toggle(title: "", isOn: .constant(true))
        Toggle(title: "", image: UIImage(), isOn: .constant(true))
        Toggle(title: "", image: .checkmark, isOn: .constant(true))
        Toggle(title: "", systemImage: "circle", isOn: .constant(true))
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Toggle(title: "", isOn: .constant(true))
        Toggle(title: "", image: UIImage(), isOn: .constant(true))
        Toggle(title: "", image: .checkmark, isOn: .constant(true))
        Toggle(title: "", systemImage: "circle", isOn: .constant(true))
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Toggle(title: "", image: UIImage(), isOn: .constant(true))
        Toggle(title: "", image: .checkmark, isOn: .constant(true))
        Toggle(title: "", systemImage: "circle", isOn: .constant(true))
    }
}
