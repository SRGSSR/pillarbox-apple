//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum ActionDSLChecks {
    @ContextualActionsContentBuilder
    static func contextualActions() -> ContextualActionsContent {
        Action("") {}
        Action("", image: UIImage()) {}
        Action("", image: .checkmark) {}
        Action("", systemImage: "circle") {}
    }

    @InfoViewActionsContentBuilder
    static func infoViewActions1() -> InfoViewActionsContent {
        Action("") {}
        Action("", image: UIImage()) {}
    }

    @InfoViewActionsContentBuilder
    static func infoViewActions2() -> InfoViewActionsContent {
        Action("", image: .checkmark) {}
        Action("", systemImage: "circle") {}
    }

    @MenuContentBuilder
    static func menu() -> MenuContent {
        Action("") {}
        Action("", image: UIImage()) {}
        Action("", image: .checkmark) {}
        Action("", systemImage: "circle") {}
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Action("") {}
        Action("", image: UIImage()) {}
        Action("", image: .checkmark) {}
        Action("", systemImage: "circle") {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Action("", image: UIImage()) {}
        Action("", image: .checkmark) {}
        Action("", systemImage: "circle") {}
    }
}
