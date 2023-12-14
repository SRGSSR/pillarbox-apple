//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMotion
import Player

final class MotionManager: ObservableObject {
    @Published private(set) var attitude: CMAttitude?
    private var motionManager = CMMotionManager()

    init(updateInterval: TimeInterval = 1 / 60) {
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            self?.attitude = motion?.attitude
        }
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
