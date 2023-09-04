//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A content providing a playable resource.
public struct Chapter: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case _resources = "resourceList"
        case blockingReason = "blockReason"
        case contentType = "type"
        case date
        case description
        case endDate = "validTo"
        case imageUrl
        case startDate = "validFrom"
        case title
        case urn
    }

    private let blockingReason: BlockingReason?

    /// The chapter URN.
    public let urn: String

    /// The chapter title
    public let title: String

    /// The chapter description.
    public let description: String?

    /// The chapter image URL.
    ///
    /// Use `SRGDataProvider.imagePublisher(for:width:)` to obtain a scaled downloadable version.
    public let imageUrl: URL

    /// The content type.
    public let contentType: ContentType

    /// The publication date.
    public let date: Date

    /// The available resources.
    public var resources: [Resource] {
        _resources ?? []
    }

    /// The date at which the content is made available.
    public let startDate: Date?

    /// The date at which the content is removed.
    public let endDate: Date?

    /// comScore analytics data.
    public var analyticsData: [String: String] {
        _analyticsData ?? [:]
    }

    /// Commanders Act analytics data.
    public var analyticsMetadata: [String: String] {
        _analyticsMetadata ?? [:]
    }

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsData: [String: String]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsMetadata: [String: String]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _resources: [Resource]?

    /// Returns whether the content is blocked for some reason.
    /// 
    /// - Parameter date: The date at which the availability must be evaluated.
    /// - Returns: The blocking reason.
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
    /// The resource recommended for playback on Apple platforms.
    var recommendedResource: Resource? {
        let resourceBuckets = Dictionary(grouping: resources) { $0.streamingMethod }
        guard let preferredMethod = StreamingMethod.supportedMethods.first(where: { method in
            resourceBuckets[method] != nil
        }) else { return nil }
        return resourceBuckets[preferredMethod]?.first
    }
}
