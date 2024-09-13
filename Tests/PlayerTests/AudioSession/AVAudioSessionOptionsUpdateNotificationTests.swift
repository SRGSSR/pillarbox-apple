//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFAudio
import Nimble

final class AVAudioSessionOptionsUpdateNotificationTests: TestCase {
    override func setUp() {
        AVAudioSession.enableUpdateNotifications()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: [])
    }

    func testUpdateNotificationWithSetCategoryModePolicyOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateNotificationWithSetCategoryModePolicyOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testUpdateNotificationWithSetCategoryModeOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateNotificationWithSetCategoryModeOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }
}
