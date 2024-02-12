//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Nimble
import XCTest

final class SimilarityTests: XCTestCase {
    func testOperatorForInstances() {
        expect(NamedPerson(name: "Alice") ~~ NamedPerson(name: "alice")).to(beTrue())
        expect(NamedPerson(name: "Alice") ~~ NamedPerson(name: "bob")).to(beFalse())
    }

    func testOperatorForOptionals() {
        let alice1: NamedPerson? = NamedPerson(name: "Alice")
        let alice2: NamedPerson? = NamedPerson(name: "alice")
        let bob = NamedPerson(name: "Bob")
        expect(alice1 ~~ alice2).to(beTrue())
        expect(alice1 ~~ bob).to(beFalse())
    }

    func testOperatorForArrays() {
        let array1 = [NamedPerson(name: "Alice"), NamedPerson(name: "Bob")]
        let array2 = [NamedPerson(name: "alice"), NamedPerson(name: "bob")]
        let array3 = [NamedPerson(name: "bob"), NamedPerson(name: "alice")]
        expect(array1 ~~ array2).to(beTrue())
        expect(array1 ~~ array3).to(beFalse())
    }

    func testBeSimilarForInstances() {
        expect(NamedPerson(name: "Alice")).to(beSimilarTo(NamedPerson(name: "alice")))
        expect(NamedPerson(name: "Alice")).notTo(beSimilarTo(NamedPerson(name: "bob")))
    }

    func testBeSimilarForOptionals() {
        let alice1: NamedPerson? = NamedPerson(name: "Alice")
        let alice2: NamedPerson? = NamedPerson(name: "alice")
        let bob = NamedPerson(name: "Bob")
        expect(alice1).to(beSimilarTo(alice2))
        expect(alice1).notTo(beNil())
        expect(alice1).notTo(beSimilarTo(bob))
    }

    func testBeSimilarForArrays() {
        let array1 = [NamedPerson(name: "Alice"), NamedPerson(name: "Bob")]
        let array2 = [NamedPerson(name: "alice"), NamedPerson(name: "bob")]
        let array3 = [NamedPerson(name: "bob"), NamedPerson(name: "alice")]
        expect(array1).to(beSimilarTo(array2))
        expect(array1).notTo(beSimilarTo(array3))
    }
}
