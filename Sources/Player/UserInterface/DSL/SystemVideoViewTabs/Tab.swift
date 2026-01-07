//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A content tab.
public struct Tab<Content> where Content: View {
    let title: String
    let identifier: String
    let content: Content

    /// Creates a tab.
    ///
    /// - Parameters:
    ///   - title: The tab title.
    ///   - identifier: A unique tab identifier. If omitted ``title`` is used instead.
    ///   - content: The tab content
    ///
    /// For optimal behavior you should ensure that each tab is assigned a unique stable identifier.
    public init(title: String, identifier: String? = nil, @ViewBuilder _ content: () -> Content) {
        self.title = title
        self.identifier = identifier ?? title
        self.content = content()
    }
}

// MARK: Info view tabs embedding

extension Tab: InfoViewTabsElement {
    // swiftlint:disable:next missing_docs
    public func viewController(reusing viewControllers: [UIViewController]) -> UIViewController {
        let viewController = viewControllers.first { $0.restorationIdentifier == identifier }
        let hostingController = hostingController(reusing: viewController)
        hostingController.title = title
        hostingController.restorationIdentifier = identifier
        return hostingController
    }

    private func hostingController(reusing viewController: UIViewController?) -> UIHostingController<Content> {
        if let hostController = viewController as? UIHostingController<Content> {
            hostController.rootView = content
            return hostController
        }
        else {
            return UIHostingController(rootView: content)
        }
    }
}
