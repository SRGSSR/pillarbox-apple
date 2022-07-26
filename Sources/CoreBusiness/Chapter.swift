//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Chapter: Decodable {
    enum CodingKeys: String, CodingKey {
        case blockingReason = "blockReason"
        case endDate = "validTo"
        case resources = "resourceList"
        case startDate = "validFrom"
        case title
        case urn
    }

    private let blockingReason: BlockingReason?

    let urn: String
    let title: String
    let resources: [Resource]

    let startDate: Date?
    let endDate: Date?

    func blockingReason(at date: Date = Date()) -> BlockingReason? {
        if blockingReason != .none {
            return blockingReason
        }
        else if let startDate, date < startDate {
            return .startDate
        }
        else if let endDate, date > endDate {
            return .endDate
        }
        else {
            return .none
        }
    }
}

extension Chapter {
    var recommendedResource: Resource? {
        resources.first { StreamingMethod.supportedMethods.contains($0.streamingMethod) }
    }
}
