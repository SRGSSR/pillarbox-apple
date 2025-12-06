import UIKit

public protocol TransportBarElement {
    associatedtype Body: TransportBarBody

    var body: Body { get }
}

extension TransportBarElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
