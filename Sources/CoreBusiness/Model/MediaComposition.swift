//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Describes a playback context.
public struct MediaComposition: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case chapterUrn
        case chapters = "chapterList"
        case show
    }

    /// The URN of the chapter to be played..
    public let chapterUrn: String

    /// The available chapters.
    public let chapters: [Chapter]

    /// The related show.
    public let show: Show?

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
}

public extension MediaComposition {
    /// The main chapter.
    var mainChapter: Chapter {
        chapters.first { $0.urn == chapterUrn }!
    }
}
