//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel

extension SRGVendor {
    var name: String {
        switch self {
        case .SRF:
            return "SRF"
        case .RTS:
            return "RTS"
        case .RSI:
            return "RSI"
        case .RTR:
            return "RTR"
        case .SWI:
            return "SWI"
        default:
            return "-"
        }
    }
}
