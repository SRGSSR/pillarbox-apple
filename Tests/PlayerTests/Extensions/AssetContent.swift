//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation
import PillarboxStreams

extension AssetContent {
    static func test(id: Character) -> Self {
        AssetContent(id: UUID(id), resource: .simple(url: Stream.onDemand.url), metadata: .empty, configuration: .default)
    }
}
