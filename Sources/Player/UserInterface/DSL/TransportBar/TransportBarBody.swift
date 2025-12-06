import UIKit

public protocol TransportBarBody {
    func toMenuElement() -> UIMenuElement
}

public struct TransportBarBodyNotSupported: TransportBarBody {
    public func toMenuElement() -> UIMenuElement {
        fatalError()
    }
}
