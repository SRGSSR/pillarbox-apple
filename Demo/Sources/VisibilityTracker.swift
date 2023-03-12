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
//   - Should be moved to the Player package (requires PublishAndRepeat)
final class VisibilityTracker: ObservableObject {
    private enum TriggerId {
        case reload
    }

    @Published private(set) var isUserInterfaceHidden: Bool {
        didSet {
            guard !isUserInterfaceHidden else { return }
            trigger.activate(for: TriggerId.reload)
        }
    }

    private let trigger = Trigger()

    init(timeout: TimeInterval = 4, isUserInterfaceHidden: Bool = false) {
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

    func toggle() {
        isUserInterfaceHidden.toggle()
    }

    func reset() {
        if !isUserInterfaceHidden {
            trigger.activate(for: TriggerId.reload)
        }
    }
}
