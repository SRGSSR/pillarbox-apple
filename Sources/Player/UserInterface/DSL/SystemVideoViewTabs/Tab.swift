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
    fileprivate var background: TabBackground<Content>

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
        self.background = TabBackground(content: content())
    }
}

public extension Tab {
    func background(_ visibility: Visibility = .automatic) -> Tab {
        var tab = self
        tab.background.visibility = visibility
        return tab
    }
}

fileprivate struct TabBackground<Content>: View where Content: View {
    let content: Content
    var visibility: Visibility = .automatic

    var body: some View {
        ZStack {
            if visibility == .visible {
                if #available(tvOS 26.0, *) {
                    Color.clear
                        .glassEffect(.clear, in: .rect(cornerRadius: 40))
                        .background {
                            Color.clear
                                .blur(radius: 1)
                                //.background(.ultraThinMaterial)
                                .padding(.vertical)
                        }
                }
                else {
                    Color.clear
                        .background(.regularMaterial, in: .rect(cornerRadius: 25))
                }
            }
            content
        }
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

    private func hostingController(reusing viewController: UIViewController?) -> UIHostingController<TabBackground<Content>> {
        if let hostController = viewController as? UIHostingController<TabBackground<Content>> {
            hostController.rootView = background
            return hostController
        }
        else if #available(iOS 16.4, tvOS 16.4, *) {
            let controller = UIHostingController(rootView: background)
            controller.safeAreaRegions = []
            return controller
        }
        else {
            return UIHostingController(rootView: background, ignoreSafeArea: true)
        }
    }
}
