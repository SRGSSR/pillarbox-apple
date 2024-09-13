//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFAudio
import Nimble

final class AVAudioSessionTests: TestCase {
    override func setUp() {
        AVAudioSession.enableUpdateNotifications()
    }

    func testCategoryNotificationWithCategoryModePolicyOptionsUpdate() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testCategoryNotificationWithCategoryModeOptionsUpdate() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }
}
