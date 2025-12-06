import UIKit

public protocol SectionElement {
    associatedtype Body: SectionBody

    var body: Body { get }
}

extension SectionElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
