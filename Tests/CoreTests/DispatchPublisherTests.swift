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

    @MainActor
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

    @MainActor
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

    @MainActor
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

    @MainActor
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
