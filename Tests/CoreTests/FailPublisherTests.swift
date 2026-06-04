//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import Nimble
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

    func testValuesPublishedAfterFailure() {
        let signal = PassthroughSubject<Void, Never>()
        let subject = PassthroughSubject<String, CancellationError>()
        let publisher = subject
            .fail(onOutputFrom: signal, with: CancellationError())
        let values = collectOutput(from: publisher, during: .milliseconds(100)) {
            subject.send("A")
            subject.send("B")
            signal.send(())
            subject.send("C")
        }
        expect(values).to(equalDiff(["A", "B"]))
    }

    func testCompletionWithoutFailure() {
        let signal = PassthroughSubject<Void, Never>()
        let subject = PassthroughSubject<String, CancellationError>()
        let publisher = subject
            .fail(onOutputFrom: signal, with: CancellationError())

        expectSuccess(from: publisher) {
            subject.send(completion: .finished)
        }
    }
}
