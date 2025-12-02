//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that can be displayed as a contextual action.
public protocol ContextualAction: UIContextualActionConvertible {}

/// A type that can be converted to contextual action.
public protocol UIContextualActionConvertible {
    /// Converts the type to an action.
    func toUIAction() -> UIAction
}
