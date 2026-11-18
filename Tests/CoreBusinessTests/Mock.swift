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

    static func dataMediaComposition(_ kind: MediaCompositionKind = .onDemand) -> Data {
        NSDataAsset(name: "MediaComposition_\(kind.rawValue)", bundle: .module)!.data
    }
}
