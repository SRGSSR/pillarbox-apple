//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum MenuDSLChecks {
    @available(iOS 17.0, tvOS 18.0, *)
    @MenuContentBuilder
    static func menu() -> MenuContent {
        Menu("") {}
        Menu("", subtitle: "") {}
        Menu("", image: UIImage()) {}
        Menu("", subtitle: "", image: UIImage()) {}
        Menu("", image: .checkmark) {}
        Menu("", subtitle: "", image: .checkmark) {}
        Menu("", systemImage: "circle") {}
        Menu("", subtitle: "", systemImage: "circle") {}
    }

    @available(iOS 17.0, tvOS 18.0, *)
    @SectionContentBuilder
    static func section() -> SectionContent {
        Menu("") {}
        Menu("", subtitle: "") {}
        Menu("", image: UIImage()) {}
        Menu("", subtitle: "", image: UIImage()) {}
        Menu("", image: .checkmark) {}
        Menu("", subtitle: "", image: .checkmark) {}
        Menu("", systemImage: "circle") {}
        Menu("", subtitle: "", systemImage: "circle") {}
    }

    @TransportBarContentBuilder
    static func transportBar() -> TransportBarContent {
        Menu("", image: UIImage()) {}
        Menu("", image: .checkmark) {}
        Menu("", systemImage: "circle") {}
    }
}
