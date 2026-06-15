//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MediaComposition: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case chapters = "chapterList"
        case chapterUrn
        case episode
        case show
    }

    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsData: [String: String]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsMetadata: [String: String]?

    let chapters: [Chapter]
    let chapterUrn: String
    let episode: Episode?
    let show: Show?

    var analyticsData: [String: String] {
        _analyticsData ?? [:]
    }

    var analyticsMetadata: [String: String] {
        _analyticsMetadata ?? [:]
    }
}

extension MediaComposition {
    func chapters(relatedTo chapter: Chapter) -> [Chapter] {
        guard chapter.contentType == .episode, chapter.mediaType == .video else { return [] }
        return chapters.filter { $0.fullLengthUrn == chapter.urn && $0.mediaType == chapter.mediaType }
    }

    func chapter(for urn: String) -> Chapter? {
        chapters.first { $0.urn == urn }
    }
}
