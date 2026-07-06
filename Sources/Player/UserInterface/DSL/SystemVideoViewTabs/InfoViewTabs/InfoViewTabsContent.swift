//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type describing the content of info view tabs.
public struct InfoViewTabsContent {
    let elements: [any InfoViewTabsElement]

    init(elements: [any InfoViewTabsElement] = []) {
        self.elements = elements
    }

    func viewControllers(reusing viewControllers: [UIViewController]) -> [UIViewController] {
        elements.map { $0.viewController(reusing: viewControllers) }
    }

    // TODO: Remove when tvOS 26 fix is not needed anymore. Use `viewControllers(reusing:)` directly.
    func viewControllers(reusing viewControllers: [UIViewController], for player: Player) -> [UIViewController] {
        builtInViewControllers(reusing: viewControllers, for: player) + self.viewControllers(reusing: viewControllers)
    }

    private func builtInViewControllers(reusing viewControllers: [UIViewController], for player: Player) -> [UIViewController] {
        guard ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 26, !player.metadata.chapters.isEmpty else {
            return []
        }
        return [
            Tab(
                String(localized: "Chapters", bundle: .module, comment: "Chapters info panel tab title"),
                identifier: "pillarbox-tvos26-chapters"
            ) {
                ChapterList(player: player)
            }
        ].map { $0.viewController(reusing: viewControllers) }
    }
}
