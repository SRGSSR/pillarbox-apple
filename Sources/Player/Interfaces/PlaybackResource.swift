//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol PlaybackResource {
    func contains(url: URL) -> Bool
}

extension PlaybackResource {
    var isLoadable: Bool {
        !isLoading && !isFailing
    }

    var isFailing: Bool {
        contains(url: .failing)
    }

    var isLoading: Bool {
        contains(url: .loading)
    }
}
