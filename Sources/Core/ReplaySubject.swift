//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

public final class ReplaySubject<Output, Failure>: Subject where Failure: Error {
    private let bufferSize: Int

    init(bufferSize: Int) {
        self.bufferSize = bufferSize
    }

    public func send(_ value: Output) {

    }

    public func send(completion: Subscribers.Completion<Failure>) {

    }

    public func send(subscription: Subscription) {

    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {

    }
}
