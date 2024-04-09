//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import UIKit

public struct MetadataItem {
    public let identifier: AVMetadataIdentifier
    public let value: Any

    // TODO: Better API than filtering by identifier and accessing with proper type. Maybe can keep MetadataItem
    //       internal?

    public var stringValue: String? {
        value as? String
    }

    public var dataValue: Data? {
        value as? Data
    }
}

extension MetadataItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        identifier.rawValue
    }
}
