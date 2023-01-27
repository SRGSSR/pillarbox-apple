//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct Chapter: Decodable {
    enum CodingKeys: String, CodingKey {
        case blockingReason = "blockReason"
        case description
        case image = "imageUrl"
        case endDate = "validTo"
        case resources = "resourceList"
        case startDate = "validFrom"
        case title
        case urn
    }

    private let blockingReason: BlockingReason?

    let urn: String
    let title: String
    let description: String?
    let image: String? // ⚠️ Ask Samuel (Not sure if we have to put an optional here!)
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
