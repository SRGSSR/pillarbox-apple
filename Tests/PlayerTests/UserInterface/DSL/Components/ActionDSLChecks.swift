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
        Action(title: "") {}
        Action(title: "", image: UIImage()) {}
        Action(title: "", image: .checkmark) {}
        Action(title: "", systemImage: "circle") {}
    }

    @InfoViewActionsContentBuilder
    static func infoViewActions1() -> InfoViewActionsContent {
        Action(title: "") {}
        Action(title: "", image: UIImage()) {}
    }

    @InfoViewActionsContentBuilder
    static func infoViewActions2() -> InfoViewActionsContent {
        Action(title: "", image: .checkmark) {}
        Action(title: "", systemImage: "circle") {}
    }

    @MenuContentBuilder
    static func menu() -> MenuContent {
        Action(title: "") {}
        Action(title: "", image: UIImage()) {}
        Action(title: "", image: .checkmark) {}
        Action(title: "", systemImage: "circle") {}
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Action(title: "") {}
        Action(title: "", image: UIImage()) {}
        Action(title: "", image: .checkmark) {}
        Action(title: "", systemImage: "circle") {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Action(title: "", image: UIImage()) {}
        Action(title: "", image: .checkmark) {}
        Action(title: "", systemImage: "circle") {}
    }
}
