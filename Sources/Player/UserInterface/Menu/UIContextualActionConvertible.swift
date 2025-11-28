//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol ContextualAction: UIContextualActionConvertible {}

public protocol UIContextualActionConvertible {
    func toUIAction() -> UIAction
}
