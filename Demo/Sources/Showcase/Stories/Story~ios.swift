//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct Story: Identifiable, Hashable {
    let id: Int
    let media: Media

    static func stories(from medias: [Media]) -> [Self] {
        medias.enumerated().map { .init(id: $0, media: $1) }
    }
}
