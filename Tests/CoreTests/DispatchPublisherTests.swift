//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Combine
import Nimble
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
}
