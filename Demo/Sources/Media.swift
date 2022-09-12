//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum MediaSource {
    case url(URL)
    case urn(String)
}

struct Media: Identifiable {
    let id: String
    let title: String
    let description: String
    let source: MediaSource
}
