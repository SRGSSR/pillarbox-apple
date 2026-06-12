//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct StandardChapter: Equatable, Codable {
    let identifier: String?
    let title: String
    let posterUrl: URL?
    let startTime: Int
    let endTime: Int
}
