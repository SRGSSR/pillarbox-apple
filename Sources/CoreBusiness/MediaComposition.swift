//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MediaComposition: Decodable {
    enum CodingKeys: String, CodingKey {
        case chapterUrn
        case chapters = "chapterList"
        case show
    }

    let chapterUrn: String
    let chapters: [Chapter]
    let show: Show?
}

extension MediaComposition {
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    var mainChapter: Chapter {
        chapters.first { $0.urn == chapterUrn }!
    }

    private static func areRedundant(chapter: Chapter, show: Show) -> Bool {
        return chapter.title.lowercased() == show.title.lowercased()
    }

    var title: String {
        guard mainChapter.contentType != .livestream else { return mainChapter.title }
        if let show, Self.areRedundant(chapter: mainChapter, show: show) {
            return Self.dateFormatter.string(from: mainChapter.date)
        }
        else {
            return mainChapter.title
        }
    }

    var subtitle: String? {
        guard mainChapter.contentType != .livestream else { return nil }
        return show?.title
    }

    var description: String? {
        mainChapter.description
    }
}
