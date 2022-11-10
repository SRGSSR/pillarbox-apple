//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// MARK: Types

struct Story: Identifiable, Hashable {
    let id: Int
    let source: Media

    static func stories(from medias: [Media]) -> [Story] {
        medias.enumerated().map { Story(id: $0, source: $1) }
    }
}
