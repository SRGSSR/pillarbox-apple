//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

public extension MediaComposition {
    /// A content providing a playable resource.
    struct Chapter: Decodable {
        enum CodingKeys: String, CodingKey {
            case _analyticsData = "analyticsData"
            case _analyticsMetadata = "analyticsMetadata"
            case _resources = "resourceList"
            case _segments = "segmentList"
            case _markIn = "fullLengthMarkIn"
            case _markOut = "fullLengthMarkOut"
            case _timeIntervals = "timeIntervalList"
            case _blockingReason = "blockReason"
            case _validFrom = "validFrom"
            case _validTo = "validTo"
            case contentType = "type"
            case date
            case description
            case imageUrl
            case mediaType
            case title
            case urn
            case fullLengthUrn
        }

        /// The chapter URN.
        public let urn: String

        /// The full-length URN.
        public let fullLengthUrn: String?

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

        /// The media type.
        public let mediaType: MediaType

        /// The publication date.
        public let date: Date

        /// Returns whether the content is blocked for some reason.
        public var blockingReason: BlockingReason? {
            _blockingReason?.blockingReason(startDate: _validFrom, endDate: _validTo)
        }

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

        /// The time interval associated with the chapter.
        public var timeIntervals: [TimeInterval] {
            _timeIntervals ?? []
        }

        /// Time range associated with the chapter.
        public var timeRange: CMTimeRange {
            guard let _markIn, let _markOut else { return .zero }
            return CMTimeRange(
                start: .init(value: _markIn, timescale: 1000),
                end: .init(value: _markOut, timescale: 1000)
            )
        }

        // swiftlint:disable:next discouraged_optional_collection
        private let _analyticsData: [String: String]?

        // swiftlint:disable:next discouraged_optional_collection
        private let _analyticsMetadata: [String: String]?

        // swiftlint:disable:next discouraged_optional_collection
        private let _segments: [Segment]?

        // swiftlint:disable:next discouraged_optional_collection
        private let _resources: [Resource]?

        // swiftlint:disable:next discouraged_optional_collection
        private let _timeIntervals: [TimeInterval]?

        private let _blockingReason: _BlockingReason?
        private let _markIn: Int64?
        private let _markOut: Int64?
        private let _validFrom: Date?
        private let _validTo: Date?
    }
}

public extension MediaComposition.Chapter {
    /// The resource recommended for playback on Apple platforms.
    var recommendedResource: MediaComposition.Resource? {
        let resourceBuckets = Dictionary(grouping: resources) { $0.streamingMethod }
        guard let preferredMethod = MediaComposition.StreamingMethod.supportedMethods.first(where: { method in
            resourceBuckets[method] != nil
        }) else { return nil }
        return resourceBuckets[preferredMethod]?.first
    }
}
