//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import Foundation
import UIKit

enum Mock {
    enum MediaCompositionKind: String {
        case missingAnalytics
        case drm
        case live
        case onDemand
        case redundant
        case mixed
        case audioChapters
    }

    static func mediaComposition(_ kind: MediaCompositionKind = .onDemand) -> MediaComposition {
        let data = NSDataAsset(name: "MediaComposition_\(kind.rawValue)", bundle: .module)!.data
        return try! DataProvider.decoder().decode(MediaComposition.self, from: data)
    }
}
