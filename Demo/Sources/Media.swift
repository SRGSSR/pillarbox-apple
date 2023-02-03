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
    let type: `Type`

    init(title: String, description: String? = nil, type: `Type`) {
        self.title = title
        self.description = description
        self.type = type
    }

    init(from template: Template) {
        self.init(
            title: template.title,
            description: template.description,
            type: template.type
        )
    }

    func playerItem() -> PlayerItem {
        let metadata = Asset.Metadata(title: title, subtitle: description)
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: metadata)
        case let .unbufferedUrl(url):
            return .simple(url: url, metadata: metadata) { item in
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
        case let .urn(urn):
            return .urn(urn)
        }
    }
}
