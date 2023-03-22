//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct MediaComposition: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case chapterUrn
        case chapters = "chapterList"
        case show
    }

    public let chapterUrn: String
    public let chapters: [Chapter]
    public let show: Show?

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
}

public extension MediaComposition {
    var mainChapter: Chapter {
        chapters.first { $0.urn == chapterUrn }!
    }
}
