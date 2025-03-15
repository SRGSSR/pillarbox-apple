//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore
import SwiftUI

// TODO: Trigger should be a template type

private enum TriggerId {
    case reset
}

public enum Skip {
    case backward
    case forward
}

// TODO: Possibly bound to a player to adjust behavior based on player state
public final class SkipTracker: ObservableObject {
    public enum State {
        case idle
        case backward(Int)
        case forward(Int)
    }

    @Published public private(set) var state: State = .idle

    private let trigger = Trigger()

    public var isActive: Bool {
        if case .idle = state {
            return false
        }
        else {
            return true
        }
    }

    public init(delay: TimeInterval = 0.4)  {
        trigger.signal(activatedBy: TriggerId.reset)
            .map { _ in
                Timer.publish(every: delay, on: .main, in: .common)
                    .autoconnect()
                    .first()
            }
            .switchToLatest()
            .map { _ in .idle }
            .assign(to: &$state)
    }

    func tap(for skip: Skip, action: () -> Void) {
        if isActive {
            singleTap(for: skip, action: action)
        }
        else {
            doubleTap(for: skip, action: action)
        }
    }

    private func singleTap(for skip: Skip, action: () -> Void) {
        switch (state, skip) {
        case let (.backward(count), .backward):
            state = .backward(count + 1)
            perform(action: action)
        case let (.forward(count), .forward):
            state = .forward(count + 1)
            perform(action: action)
        default:
            break
        }
    }

    private func doubleTap(for skip: Skip, action: () -> Void) {
        switch (state, skip) {
        case (.forward, .forward), (.backward, .backward):
            break
        case (.idle, .backward):
            state = .backward(1)
            perform(action: action)
        case (.idle, .forward):
            state = .forward(1)
            perform(action: action)
        case (.forward, .backward):
            state = .backward(0)
            perform(action: action)
        case (.backward, .forward):
            state = .forward(0)
            perform(action: action)
        }
    }

    private func perform(action: () -> Void) {
        action()
        reset()
    }

    private func reset() {
        trigger.activate(for: TriggerId.reset)
    }
}

public func SkipGesture(
    tracker: SkipTracker,
    player: Player,
    coordinateSpace: CoordinateSpace = .local,
    resolver: @escaping (CGPoint) -> Skip
) -> _EndedGesture<SpatialTapGesture> {
    SpatialTapGesture(count: tracker.isActive ? 1 : 2, coordinateSpace: coordinateSpace)
        .onEnded { value in
            let skip = resolver(value.location)
            switch skip {
            case .backward:
                tracker.tap(for: .backward) {
                    player.skipBackward()
                }
            case .forward:
                tracker.tap(for: .forward) {
                    player.skipForward()
                }
            }
        }
}

private struct SkipPreview: View {
    @StateObject var tracker = SkipTracker()

    var body: some View {
        VStack {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    Color.red
                    Color.yellow
                }
                .gesture(
                    SkipGesture(tracker: tracker, player: Player()) { point in
                        point.x < proxy.size.width / 2 ? .backward : .forward
                    }
                )
            }
            Text(status)
        }
        .ignoresSafeArea()
    }

    private var status: String {
        switch tracker.state {
        case .idle:
            "Idle"
        case let .backward(count):
            "-\(count)"
        case let .forward(count):
            "+\(count)"
        }
    }
}

#Preview {
    SkipPreview()
}
