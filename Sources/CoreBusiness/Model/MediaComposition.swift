//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A description of a playback context.
public struct MediaComposition: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case chapterUrn
        case _chapters = "chapterList"
        case episode
        case show
    }

    /// The URN of the chapter to be played.
    public let chapterUrn: String

    /// The available chapters.
    public var chapters: [Chapter] {
        _chapters.filter { $0.fullLengthUrn == chapterUrn && $0.mediaType == mainChapter.mediaType }
    }

    /// The related show.
    public let show: Show?

    /// The episode information.
    public let episode: Episode?

    /// comScore analytics data.
    public var analyticsData: [String: String] {
        _analyticsData ?? [:]
    }

    /// Commanders Act analytics data.
    public var analyticsMetadata: [String: String] {
        _analyticsMetadata ?? [:]
    }

    var allChapters: [Chapter] {
        [mainChapter] + chapters
    }

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsData: [String: String]?

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsMetadata: [String: String]?

    private let _chapters: [Chapter]
}

public extension MediaComposition {
    /// The main chapter.
    var mainChapter: Chapter {
        _chapters.first { $0.urn == chapterUrn }!
    }
}
