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
    private let height: CGFloat?
    let elements: [any InfoViewTabsElement]

    init(height: CGFloat? = nil, elements: [any InfoViewTabsElement] = []) {
        self.elements = elements
        self.height = height
    }

    func viewControllers(reusing viewControllers: [UIViewController]) -> [UIViewController] {
        elements.map { element in
            let controller = element.viewController(reusing: viewControllers)
            if let height {
                controller.preferredContentSize = CGSize(width: 0, height: height)
            }
            return controller
        }
    }
}
