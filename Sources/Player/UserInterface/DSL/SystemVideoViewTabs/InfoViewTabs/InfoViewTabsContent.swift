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
    let children: [any InfoViewTabsElement]
    let height: CGFloat?

    init(height: CGFloat? = nil, children: [any InfoViewTabsElement] = []) {
        self.children = children
        self.height = height
    }

    func viewControllers(reusing viewControllers: [UIViewController]) -> [UIViewController] {
        children.map { $0.viewController(reusing: viewControllers) }
    }
}
