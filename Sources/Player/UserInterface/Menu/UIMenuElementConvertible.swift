//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that can be displayed as element of an inline menu.
public protocol InlineMenuElement: UIMenuElementConvertible {}

/// A type that can be displayed as element of a menu.
public protocol MenuElement: UIMenuElementConvertible {}

/// A type that can be displayed as element of a selection menu.
public protocol SelectionMenuElement: UIMenuElementConvertible {}

/// A type that can be displayed as element of a transport bar.
public protocol TransportBarElement: UIMenuElementConvertible {}

/// A type that can be converted to a menu element.
public protocol UIMenuElementConvertible {
    /// Converts the type to a menu element.
    func toUIMenuElement() -> UIMenuElement
}
