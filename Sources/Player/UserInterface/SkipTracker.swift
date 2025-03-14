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

    func singleTap(for skip: Skip, action: () -> Void) {
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

    func doubleTap(for skip: Skip, action: () -> Void) {
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

private struct SkipModifier: ViewModifier {
    let skip: Skip
    let action: () -> Void

    @ObservedObject var tracker: SkipTracker

    func body(content: Content) -> some View {
        content
            .gesture(tapGesture())
    }

    private func tapGesture() -> some Gesture {
        TapGesture(count: tracker.isActive ? 1 : 2)
            .onEnded {
                if tracker.isActive {
                    tracker.singleTap(for: skip, action: action)
                }
                else {
                    tracker.doubleTap(for: skip, action: action)
                }
            }
    }
}

public extension View {
    func skipGesture(_ skip: Skip, tracker: SkipTracker, action: @escaping () -> Void) -> some View {
        modifier(SkipModifier(skip: skip, action: action, tracker: tracker))
    }
}

private struct SkipPreview: View {
    @StateObject var tracker = SkipTracker()

    var body: some View {
        VStack {
            HStack {
                Color.red
                    .skipGesture(.backward, tracker: tracker) {
                        print("--> back")
                    }
                Color.yellow
                    .skipGesture(.forward, tracker: tracker) {
                        print("--> forward")
                    }
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
