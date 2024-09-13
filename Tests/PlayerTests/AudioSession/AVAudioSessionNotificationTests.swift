//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFAudio
import Nimble

final class AVAudioSessionNotificationTests: TestCase {
    override func setUp() {
        AVAudioSession.enableUpdateNotifications()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: [])
    }

    func testUpdateWithSetCategoryModePolicyOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateWithSetCategoryModePolicyOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testUpdateWithSetCategoryModeOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateWithSetCategoryModeOptions() throws {
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }
}
