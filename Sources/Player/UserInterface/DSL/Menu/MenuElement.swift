import UIKit

public protocol MenuElement {
    associatedtype Body: MenuBody

    var body: Body { get }
}

extension MenuElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
