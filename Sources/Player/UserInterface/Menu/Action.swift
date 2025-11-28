//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct ActionInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct ActionInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct ActionInSelectionMenu: SelectionMenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { action in
            handler()
            action.state = .on
        }
    }
}

public struct ActionInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct Action<Body> {
    private let body: Body
}

extension Action : UIMenuElementConvertible where Body: UIMenuElementConvertible {
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension Action: InlineMenuElement where Body == ActionInInlineMenu {
    public init(title: String, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.body = .init(title: title, image: image, handler: handler)
    }
}

extension Action: MenuElement where Body == ActionInMenu {
    public init(title: String, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.body = .init(title: title, image: image, handler: handler)
    }
}

extension Action: SelectionMenuElement where Body == ActionInSelectionMenu {
    public init(title: String, image: UIImage? = nil, handler: @escaping () -> Void = {}) {
        self.body = .init(title: title, image: image, handler: handler)
    }
}

extension Action: TransportBarElement where Body == ActionInTransportBar {
    public init(title: String, image: UIImage, handler: @escaping () -> Void) {
        self.body = .init(title: title, image: image, handler: handler)
    }
}
