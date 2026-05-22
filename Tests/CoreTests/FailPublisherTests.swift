//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import PillarboxCircumspect
import XCTest

private struct CancellationError: Error {}

final class FailPublisherTests: XCTestCase {
    func testNoFailOnOutput() {
        let signal = PassthroughSubject<Void, Never>()
        let subject = PassthroughSubject<String, CancellationError>()
        let publisher = subject
            .fail(onOutputFrom: signal, with: CancellationError())
        expectEqualPublished(values: ["A", "B"], from: publisher) {
            subject.send("A")
            subject.send("B")
        }
    }

    func testFailOnOutput() {
        let signal = PassthroughSubject<Void, Never>()
        let subject = PassthroughSubject<String, CancellationError>()
        let publisher = subject
            .fail(onOutputFrom: signal, with: CancellationError())
        expectFailure(CancellationError(), from: publisher) {
            signal.send(())
        }
    }
}
