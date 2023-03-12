//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit


/// A gesture recognizer which detects all kinds of user activities and calls the associated action on its target if any
/// activity is detected.
final class ActivityGestureRecognizer: UIGestureRecognizer {
    // Heavily inspired by MPActivityGestureRecognizer from the MediaPlayer framework
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
        delaysTouchesEnded = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        stopReportingOngoingActivity()
        reportOngoingActivity()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .changed
        reportOngoingActivity()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        stopReportingOngoingActivity()
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        stopReportingOngoingActivity()
        state = .cancelled
    }

    @objc
    private func reportOngoingActivity() {
        state = .began
        perform(#selector(reportOngoingActivity), with: nil, afterDelay: 1.0)
    }

    private func stopReportingOngoingActivity() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reportOngoingActivity), object: nil)
    }
}
