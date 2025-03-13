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
    @Published private(set) var isEnabled = false

    private let trigger = Trigger()
    private var lastSkip: Skip? = nil

    public init(delay: TimeInterval = 0.4)  {
        trigger.signal(activatedBy: TriggerId.reset)
            .map { _ in
                Timer.publish(every: delay, on: .main, in: .common)
                    .autoconnect()
                    .first()
            }
            .switchToLatest()
            .map { _ in false }
            .assign(to: &$isEnabled)
    }

    func enable(for skip: Skip) {
        if let lastSkip, lastSkip != skip {
            isEnabled = false
        }
        else {
            isEnabled = true
        }
    }

    func skip(_ skip: Skip, action: () -> Void) {
        action()
        reset()
        lastSkip = skip
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
            .simultaneousGesture(singleTapGesture(), isEnabled: tracker.isEnabled)
            .simultaneousGesture(doubleTapGesture(), isEnabled: !tracker.isEnabled)
    }

    private func singleTapGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                tracker.skip(skip, action: action)
            }
    }

    private func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                tracker.enable(for: skip)
                tracker.skip(skip, action: action)
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
        .ignoresSafeArea()
    }
}

#Preview {
    SkipPreview()
}
