import UIKit

public protocol MenuBody {
    func toMenuElement() -> UIMenuElement
}

public struct MenuBodyNotSupported: MenuBody {
    public func toMenuElement() -> UIMenuElement {
        fatalError()
    }
}
