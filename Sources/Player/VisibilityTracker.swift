//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import Player
import SwiftUI

// FIXME:
//   - Should not trigger when the player is paused
public final class VisibilityTracker: ObservableObject {
    private enum TriggerId {
        case reload
    }

    @Published public private(set) var isUserInterfaceHidden: Bool {
        didSet {
            guard !isUserInterfaceHidden else { return }
            trigger.activate(for: TriggerId.reload)
        }
    }

    private let trigger = Trigger()

    public init(timeout: TimeInterval = 4, isUserInterfaceHidden: Bool = false) {
        self.isUserInterfaceHidden = isUserInterfaceHidden
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
            Timer.publish(every: timeout, on: .main, in: .common)
                .autoconnect()
                .first()
        }
        .map { _ in true }
        .receiveOnMainThread()
        .assign(to: &$isUserInterfaceHidden)
    }

    public func toggle() {
        isUserInterfaceHidden.toggle()
    }

    public func reset() {
        if !isUserInterfaceHidden {
            trigger.activate(for: TriggerId.reload)
        }
    }
}
