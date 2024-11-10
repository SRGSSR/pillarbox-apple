//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

public extension XCTestCase {
    /// Expects a publisher to emit at least a value.
    func expectValue<P>(
        from publisher: P,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where P: Publisher {
        expectSuccess(from: publisher.first(), timeout: timeout, file: file, line: line, while: executing)
    }

    /// Expects an observable object to publish at least a change.
    func expectChange<O>(
        from object: O,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) where O: ObservableObject {
        expectValue(from: object.objectWillChange, timeout: timeout, file: file, line: line, while: executing)
    }
}
