//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import UIKit

struct MetadataItem {
    let identifier: AVMetadataIdentifier
    let value: Any

    var stringValue: String? {
        value as? String
    }

    var integerValue: Int? {
        value as? Int
    }

    var doubleValue: Double? {
        value as? Double
    }

    var dateValue: Date? {
        value as? Date
    }

    var dataValue: Data? {
        value as? Data
    }
}

extension MetadataItem: CustomDebugStringConvertible {
    var debugDescription: String {
        identifier.rawValue
    }
}
