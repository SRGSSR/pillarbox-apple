//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftUI
import UIKit

/// A type that describing the content of custom info view controllers on tvOS.
public struct InfoViewTabsContent {
    let elements: [any InfoViewTabsElement]
    let height: CGFloat?

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
