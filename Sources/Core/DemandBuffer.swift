//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule

// TODO: Locks
final class DemandBuffer<T> {
    enum Action {
        case produce(T)
        case complete
    }

    private(set) var values = Deque<T>()
    private(set) var requested: Subscribers.Demand = .none

    init(_ values: [T] = []) {
        self.values = .init(values)
    }

    func append(_ value: T) -> [Action] {
        switch requested {
        case .unlimited:
            return [.produce(value)]
        default:
            values.append(value)
            return flush()
        }
    }

    func request(_ demand: Subscribers.Demand) -> [Action] {
        requested += demand
        return flush()
    }

    private func flush() -> [Action] {
        var actions = [Action]()
        while requested > 0, let value = values.popFirst() {
            actions.append(.produce(value))
            requested -= 1
            if requested == 0 {
                actions.append(.complete)
            }
        }
        return actions
    }
}

extension DemandBuffer.Action: Equatable where T: Equatable {}
