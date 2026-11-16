//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MediaCompositionResponse {
    let mediaComposition: MediaComposition
    let data: Data
    let response: URLResponse

    var isScheduledLivestream: Bool {
        let mainChapter = mediaComposition.chapter(for: mediaComposition.chapterUrn)
        return mainChapter?.contentType == .scheduledLivestream
    }

    init(data: Data, response: URLResponse) throws {
        self.data = data
        self.response = response
        self.mediaComposition = try Self.decoder().decode(MediaComposition.self, from: data)
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension MediaCompositionResponse: Equatable {
    static func == (lhs: borrowing MediaCompositionResponse, rhs: borrowing MediaCompositionResponse) -> Bool {
        lhs.data == rhs.data
    }
}
