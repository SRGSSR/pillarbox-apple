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
        case _segments = "segmentList"
        case blockingReason = "blockReason"
        case contentType = "type"
        case date
        case description
        case imageUrl
        case title
        case urn
    }

    /// The chapter URN.
    public let urn: String

    /// The chapter title
    public let title: String

    /// The chapter description.
    public let description: String?

    /// The chapter image URL.
    ///
    /// Use `DataProvider.imagePublisher(for:width:)` to obtain a scaled downloadable version.
    public let imageUrl: URL

    /// The content type.
    public let contentType: ContentType

    /// The publication date.
    public let date: Date

    /// Returns whether the content is blocked for some reason.
    public let blockingReason: BlockingReason?

    /// The available segments.
    public var segments: [Segment] {
        _segments ?? []
    }

    /// The available resources.
    public var resources: [Resource] {
        _resources ?? []
    }

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
    private let _segments: [Segment]?

    // swiftlint:disable:next discouraged_optional_collection
    private let _resources: [Resource]?
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
