//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Foundation
import UIKit

enum Mock {
    enum ChapterKind: String {
        case standard
        case geoblocked
        case timeLimited
    }

    enum MediaCompositionKind: String {
        case drm
        case onDemand
        case live
    }

    static func chapter(_ kind: ChapterKind = .standard) -> Chapter {
        let data = NSDataAsset(name: "Chapter_\(kind.rawValue)", bundle: .module)!.data
        return try! DataProvider.decoder().decode(Chapter.self, from: data)
    }

    static func mediaComposition(_ kind: MediaCompositionKind = .onDemand) -> MediaComposition {
        let data = NSDataAsset(name: "MediaComposition_\(kind.rawValue)", bundle: .module)!.data
        return try! DataProvider.decoder().decode(MediaComposition.self, from: data)
    }
}
