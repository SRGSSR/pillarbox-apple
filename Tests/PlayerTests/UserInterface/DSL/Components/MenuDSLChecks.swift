//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum MenuDSLChecks {
    @MenuContentBuilder
    static func menu() -> MenuContent {
        Menu(title: "") {}
        Menu(title: "", image: UIImage()) {}
        Menu(title: "", image: .checkmark) {}
        Menu(title: "", systemImage: "circle") {}
    }

    @SectionContentBuilder
    static func section() -> SectionContent {
        Menu(title: "") {}
        Menu(title: "", image: UIImage()) {}
        Menu(title: "", image: .checkmark) {}
        Menu(title: "", systemImage: "circle") {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Menu(title: "", image: UIImage()) {}
        Menu(title: "", image: .checkmark) {}
        Menu(title: "", systemImage: "circle") {}
    }
}
