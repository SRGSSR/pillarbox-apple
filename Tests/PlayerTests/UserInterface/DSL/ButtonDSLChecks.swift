//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum ButtonDSLChecks {
    @ContextualActionsContentBuilder
    static func contextualActions() -> ContextualActionsContent {
        Button("") {}
        Button("", image: UIImage()) {}
        Button("", image: .checkmark) {}
        Button("", systemImage: "circle") {}
    }

    @InfoViewActionsContentBuilder
    static func infoViewActions1() -> InfoViewActionsContent {
        Button("") {}
        Button("", image: UIImage()) {}
    }

    @InfoViewActionsContentBuilder
    static func infoViewActions2() -> InfoViewActionsContent {
        Button("", image: .checkmark) {}
        Button("", systemImage: "circle") {}
    }

    @MenuContentBuilder
    static func menu() -> MenuContent {
        Button("") {}
        Button("", subtitle: "") {}
        Button("", image: UIImage()) {}
        Button("", subtitle: "", image: UIImage()) {}
        Button("", image: .checkmark) {}
        Button("", subtitle: "", image: .checkmark) {}
        Button("", systemImage: "circle") {}
        Button("", subtitle: "", systemImage: "circle") {}
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Button("") {}
        Button("", subtitle: "") {}
        Button("", image: UIImage()) {}
        Button("", subtitle: "", image: UIImage()) {}
        Button("", image: .checkmark) {}
        Button("", subtitle: "", image: .checkmark) {}
        Button("", systemImage: "circle") {}
        Button("", subtitle: "", systemImage: "circle") {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Button("", image: UIImage()) {}
        Button("", image: .checkmark) {}
        Button("", systemImage: "circle") {}
    }
}
