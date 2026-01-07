//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import SwiftUI
import UIKit

/// A type that describing the content of custom info view controllers on tvOS.
public struct CustomInfoViewsContent {
    let views: [CustomInfoView]
    let height: CGFloat?

    init(height: CGFloat? = nil, views: [CustomInfoView] = []) {
        self.views = views
        self.height = height
    }

    func toUIViewControllers(using coordinator: CustomInfoViewsCoordinator) -> [UIViewController] {
        views.map { infoView in
            let hostingController = coordinator.controller(using: infoView)
            if let height {
                hostingController.view.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
            hostingController.title = infoView.title
            return hostingController
        }
    }
}
