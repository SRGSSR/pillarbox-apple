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
        case chapters = "chapterList"
        case chapterUrn
        case episode
        case show
    }

    /// The URN of the chapter to be played.
    public let chapterUrn: String

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

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsData: [String: String]?

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsMetadata: [String: String]?

    private let chapters: [Chapter]
}

extension MediaComposition {
    func chapters(relatedTo chapter: Chapter) -> [Chapter] {
        guard chapter.contentType == .episode else { return [] }
        return chapters.filter { $0.fullLengthUrn == chapter.urn && $0.mediaType == chapter.mediaType }
    }

    func chapter(for urn: String) -> Chapter? {
        chapters.first { $0.urn == urn }
    }
}
