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
        Toggle("", isOn: .constant(true))
        Toggle("", image: UIImage(), isOn: .constant(true))
        Toggle("", image: .checkmark, isOn: .constant(true))
        Toggle("", systemImage: "circle", isOn: .constant(true))
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Toggle("", isOn: .constant(true))
        Toggle("", image: UIImage(), isOn: .constant(true))
        Toggle("", image: .checkmark, isOn: .constant(true))
        Toggle("", systemImage: "circle", isOn: .constant(true))
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Toggle("", image: UIImage(), isOn: .constant(true))
        Toggle("", image: .checkmark, isOn: .constant(true))
        Toggle("", systemImage: "circle", isOn: .constant(true))
    }
}
