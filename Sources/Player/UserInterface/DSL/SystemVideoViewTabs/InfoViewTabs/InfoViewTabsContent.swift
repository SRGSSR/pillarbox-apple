//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftUI
import UIKit

/// A type that describing the content of info view tabs.
public struct InfoViewTabsContent {
    let elements: [any InfoViewTabsElement]

    init(elements: [any InfoViewTabsElement] = []) {
        self.elements = elements
    }

    func viewControllers(reusing viewControllers: [UIViewController]) -> [UIViewController] {
        elements.map { $0.viewController(reusing: viewControllers) }
    }
}
