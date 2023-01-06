//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// MARK: Types

struct Story: Identifiable, Hashable {
    let id: Int
    let template: Template

    static func stories(from medias: [Template]) -> [Self] {
        medias.enumerated().map { .init(id: $0, template: $1) }
    }
}
