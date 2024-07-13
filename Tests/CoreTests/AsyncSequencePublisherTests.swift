//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

private struct MockError: Error {}

#if compiler(>=6.0)
@available(iOS 18.0, tvOS 18.0, *)
final class AsyncSequencePublisherTests: XCTestCase {
    func testEmptySequence() {
        let sequence = Empty<Void, Never>().values
        let publisher = AsyncSequencePublisher(from: sequence)
        expectNothingPublished(from: publisher, during: .milliseconds(100))
    }

    func testFiniteSequence() {
        let sequence = [1, 2, 3].publisher.values
        let publisher = AsyncSequencePublisher(from: sequence)
        expectOnlyEqualPublished(values: [1, 2, 3], from: publisher)
    }

    func testFailure() {
        let sequence = Fail<Int, Error>(error: MockError()).values
        let publisher = AsyncSequencePublisher(from: sequence)
        expectFailure(from: publisher)
    }
}
#endif
