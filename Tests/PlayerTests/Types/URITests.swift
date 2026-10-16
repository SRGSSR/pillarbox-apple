//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation
import Nimble

final class URITests: TestCase {
    func testDataUri() {
        expect(URI.dataUri(for: Data(repeating: 1, count: 16))).to(equal("data:application/octet-stream;base64,AQEBAQEBAQEBAQEBAQEBAQ=="))
    }
}
