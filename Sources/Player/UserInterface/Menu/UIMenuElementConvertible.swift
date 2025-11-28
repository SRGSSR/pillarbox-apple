//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol InlineMenuElement: UIMenuElementConvertible {}
public protocol MenuElement: UIMenuElementConvertible {}
public protocol SelectionMenuElement: UIMenuElementConvertible {}
public protocol TransportBarElement: UIMenuElementConvertible {}

public protocol UIMenuElementConvertible {
    func toUIMenuElement() -> UIMenuElement
}
