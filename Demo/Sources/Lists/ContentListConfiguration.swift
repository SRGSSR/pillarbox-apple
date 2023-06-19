//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel

struct ContentListConfiguration: Hashable, Identifiable {
    let kind: ContentListKind
    let vendor: SRGVendor

    var id: String {
        "\(kind.id)_\(vendor.rawValue)"
    }

    var name: String {
        kind.radioChannel?.name ?? vendor.name
    }
}
