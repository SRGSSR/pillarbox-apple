import UIKit

public protocol SectionBody {
    func toMenuElement() -> UIMenuElement
}

public struct SectionBodyNotSupported: SectionBody {
    public func toMenuElement() -> UIMenuElement {
        fatalError()
    }
}
