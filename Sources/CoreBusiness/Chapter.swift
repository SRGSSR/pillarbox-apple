//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct Chapter: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case blockingReason = "blockReason"
        case contentType = "type"
        case date
        case description
        case endDate = "validTo"
        case imageUrl
        case resources = "resourceList"
        case startDate = "validFrom"
        case title
        case urn
    }

    private let blockingReason: BlockingReason?

    public let urn: String
    public let title: String
    public let description: String?
    public let imageUrl: URL
    public let contentType: ContentType
    public let date: Date
    public let resources: [Resource]
    public let startDate: Date?
    public let endDate: Date?

    public var analyticsData: [String: String] {
        _analyticsData ?? [:]
    }

    public var analyticsMetadata: [String: String] {
        _analyticsMetadata ?? [:]
    }

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsData: [String: String]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsMetadata: [String: String]?

    public func blockingReason(at date: Date = Date()) -> BlockingReason? {
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

public extension Chapter {
    var recommendedResource: Resource? {
        resources.first { StreamingMethod.supportedMethods.contains($0.streamingMethod) }
    }
}
