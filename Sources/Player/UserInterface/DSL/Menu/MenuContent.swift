import UIKit

public struct MenuContent {
    private let children: [any MenuElement]

    init(children: [any MenuElement] = []) {
        self.children = children
    }

    func toMenuElements() -> [UIMenuElement] {
        children.map { $0.toMenuElement() }
    }
}
