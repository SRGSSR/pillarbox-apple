//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Foundation
import Player

struct Media: Hashable, Identifiable {
    enum `Type`: Hashable {
        case url(URL)
        case unbufferedUrl(URL)
        case urn(String)
    }

    let id = UUID()
    let title: String
    let description: String?
    let type: Media.`Type`

    init(title: String, description: String? = nil, type: Media.`Type`) {
        self.title = title
        self.description = description
        self.type = type
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            return PlayerItem(url: url)
        case let .unbufferedUrl(url):
            return PlayerItem(url: url) { item in
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
        case let .urn(urn):
            return PlayerItem(urn: urn)
        }
    }
}
