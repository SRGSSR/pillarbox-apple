import UIKit

public struct SectionContent {
    private let children: [any SectionElement]

    init(children: [any SectionElement] = []) {
        self.children = children
    }

    func toMenuElements() -> [UIMenuElement] {
        children.map { $0.toMenuElement() }
    }
}
