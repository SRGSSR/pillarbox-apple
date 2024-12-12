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

final class DispatchPublisherTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testReceiveOnMainThreadFromMainThread() {
        var value = 0
        Just(3)
            .receiveOnMainThread()
            .sink { i in
                expect(Thread.isMainThread).to(beTrue())
                value = i
            }
            .store(in: &cancellables)
        expect(value).to(equal(3))
    }

    func testReceiveOnMainThreadFromBackgroundThread() {
        var value = 0
        Just(3)
            .receive(on: DispatchQueue(label: "com.srgssr.pillarbox-tests"))
            .receiveOnMainThread()
            .sink { i in
                expect(Thread.isMainThread).to(beTrue())
                value = i
            }
            .store(in: &cancellables)
        expect(value).to(equal(0))
    }

    func testStandardReceiveOnMainThreadFromMainThread() {
        var value = 0
        Just(3)
            .receive(on: DispatchQueue.main)
            .sink { i in
                expect(Thread.isMainThread).to(beTrue())
                value = i
            }
            .store(in: &cancellables)
        expect(value).to(equal(0))
    }

    func testStandardReceiveOnMainThreadFromBackgroundThread() {
        var value = 0
        Just(3)
            .receive(on: DispatchQueue(label: "com.srgssr.pillarbox-tests"))
            .receive(on: DispatchQueue.main)
            .sink { i in
                expect(Thread.isMainThread).to(beTrue())
                value = i
            }
            .store(in: &cancellables)
        expect(value).to(equal(0))
    }

    func testReceiveOnMainThreadReceivesAllOutputFromMainThread() {
        let publisher = [1, 2, 3].publisher
            .receiveOnMainThread()
        expectOnlyEqualPublished(values: [1, 2, 3], from: publisher)
    }

    func testReceiveOnMainThreadReceivesAllOutputFromBackgroundThreads() {
        let publisher = [1, 2, 3].publisher
            .receive(on: DispatchQueue(label: "com.srgssr.pillarbox-tests"))
            .receiveOnMainThread()
        expectOnlyEqualPublished(values: [1, 2, 3], from: publisher)
    }

    func testDelayIfNeededOutputOrderingWithNonZeroDelay() {
        let delayedPublisher = [1, 2, 3].publisher
            .delayIfNeeded(for: 0.1, scheduler: DispatchQueue.main)
        let subject = CurrentValueSubject<Int, Never>(0)
        expectAtLeastEqualPublished(values: [0, 1, 2, 3], from: Publishers.Merge(delayedPublisher, subject))
    }

    func testDelayIfNeededOutputOrderingWithZeroDelay() {
        let delayedPublisher = [1, 2, 3].publisher
            .delayIfNeeded(for: 0, scheduler: DispatchQueue.main)
        let subject = CurrentValueSubject<Int, Never>(0)
        expectAtLeastEqualPublished(values: [1, 2, 3, 0], from: Publishers.Merge(delayedPublisher, subject))
    }
}
