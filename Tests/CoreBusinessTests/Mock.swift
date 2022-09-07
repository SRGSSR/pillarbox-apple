//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Foundation
import UIKit

enum Mock {
    enum MediaCompositionKind: String {
        case onDemand
        case live
    }

    static func mediaComposition(_ kind: MediaCompositionKind = .onDemand) -> MediaComposition {
        let data = NSDataAsset(name: "MediaComposition_\(kind.rawValue)", bundle: .module)!.data
        return try! JSONDecoder().decode(MediaComposition.self, from: data)
    }
}
