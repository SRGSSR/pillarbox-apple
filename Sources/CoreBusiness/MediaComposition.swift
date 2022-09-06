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
    }

    let chapterUrn: String
    let chapters: [Chapter]
}

extension MediaComposition {
    var mainChapter: Chapter {
        chapters.first { $0.urn == chapterUrn }!
    }
}
