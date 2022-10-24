//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Circumspect

import Nimble
import XCTest

final class SimilarityTests: XCTestCase {
    func testSimilarInstances() {
        expect(NamedPerson(name: "Alice") ~= NamedPerson(name: "alice")).to(beTrue())
        expect(NamedPerson(name: "Alice") ~= NamedPerson(name: "bob")).to(beFalse())
    }

    func testSimilarOptionals() {
        let alice1: NamedPerson? = NamedPerson(name: "Alice")
        let alice2: NamedPerson? = NamedPerson(name: "alice")
        let bob = NamedPerson(name: "Bob")
        expect(alice1 ~= alice2).to(beTrue())
        expect(alice1 ~= bob).to(beFalse())
    }

    func testSimilarArrays() {
        let array1 = [NamedPerson(name: "Alice"), NamedPerson(name: "Bob")]
        let array2 = [NamedPerson(name: "alice"), NamedPerson(name: "bob")]
        let array3 = [NamedPerson(name: "bob"), NamedPerson(name: "alice")]
        expect(array1 ~= array2).to(beTrue())
        expect(array1 ~= array3).to(beFalse())
    }

    func testEqualForSimilarInstances() {
        expect(NamedPerson(name: "Alice")).to(equal(NamedPerson(name: "alice")))
        expect(NamedPerson(name: "Alice")).notTo(equal(NamedPerson(name: "bob")))
    }

    func testEqualForSimilarOptionals() {
        let alice1: NamedPerson? = NamedPerson(name: "Alice")
        let alice2: NamedPerson? = NamedPerson(name: "alice")
        let bob = NamedPerson(name: "Bob")
        expect(alice1).to(equal(alice2))
        expect(alice1).notTo(beNil())
        expect(alice1).notTo(equal(bob))
    }

    func testEqualForSimilarArrays() {
        let array1 = [NamedPerson(name: "Alice"), NamedPerson(name: "Bob")]
        let array2 = [NamedPerson(name: "alice"), NamedPerson(name: "bob")]
        let array3 = [NamedPerson(name: "bob"), NamedPerson(name: "alice")]
        expect(array1).to(equal(array2))
        expect(array1).notTo(equal(array3))
    }
}
