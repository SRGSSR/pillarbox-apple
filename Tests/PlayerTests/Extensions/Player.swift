//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation

extension Player {
    var urls: [URL] {
        queuePlayer.items().compactMap(\.url)
    }
}
