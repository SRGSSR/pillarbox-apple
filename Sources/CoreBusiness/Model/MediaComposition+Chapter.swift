//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

extension MediaComposition {
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

        // swiftlint:disable:next discouraged_optional_collection
        private let _analyticsData: [String: String]?
        // swiftlint:disable:next discouraged_optional_collection
        private let _analyticsMetadata: [String: String]?
        // swiftlint:disable:next discouraged_optional_collection
        private let _resources: [Resource]?
        // swiftlint:disable:next discouraged_optional_collection
        private let _segments: [Segment]?
        // swiftlint:disable:next discouraged_optional_collection
        private let _timeIntervals: [TimeInterval]?

        private let _blockingReason: _BlockingReason?
        private let _markIn: Int64?
        private let _markOut: Int64?
        private let _validFrom: Date?
        private let _validTo: Date?

        let urn: String
        let fullLengthUrn: String?
        let title: String
        let description: String?
        let imageUrl: URL
        let contentType: ContentType
        let mediaType: MediaType
        let date: Date

        var analyticsData: [String: String] {
            _analyticsData ?? [:]
        }

        var analyticsMetadata: [String: String] {
            _analyticsMetadata ?? [:]
        }

        var blockingReason: BlockingReason? {
            _blockingReason?.blockingReason(startDate: _validFrom, endDate: _validTo)
        }

        var resources: [Resource] {
            _resources ?? []
        }

        var segments: [Segment] {
            _segments ?? []
        }

        var timeIntervals: [TimeInterval] {
            _timeIntervals ?? []
        }

        var timeRange: CMTimeRange {
            guard let _markIn, let _markOut else { return .zero }
            return CMTimeRange(
                start: .init(value: _markIn, timescale: 1000),
                end: .init(value: _markOut, timescale: 1000)
            )
        }
    }
}
extension MediaComposition.Chapter {
    var recommendedResource: MediaComposition.Resource? {
        let resourceBuckets = Dictionary(grouping: resources) { $0.streamingMethod }
        guard let preferredMethod = MediaComposition.StreamingMethod.supportedMethods.first(where: { method in
            resourceBuckets[method] != nil
        }) else { return nil }
        return resourceBuckets[preferredMethod]?.first
    }
}
