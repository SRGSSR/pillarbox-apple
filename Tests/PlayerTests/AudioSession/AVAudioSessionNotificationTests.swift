//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFAudio
import Nimble
import XCTest

final class AVAudioSessionNotificationTests: TestCase {
    override func setUp() {
        if #unavailable(iOS 18, tvOS 18) {
            AVAudioSession.enableUpdateNotifications()
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: [])
        }
    }

    func testUpdateWithSetCategoryModePolicyOptions() throws {
        if #available(iOS 18, tvOS 18, *) {
            throw XCTSkip("Skipped on iOS/tvOS 18 and later.")
        }
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateWithSetCategoryModePolicyOptions() throws {
        if #available(iOS 18, tvOS 18, *) {
            throw XCTSkip("Skipped on iOS/tvOS 18 and later.")
        }
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, policy: .default, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testUpdateWithSetCategoryModeOptions() throws {
        if #available(iOS 18, tvOS 18, *) {
            throw XCTSkip("Skipped on iOS/tvOS 18 and later.")
        }
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateWithSetCategoryModeOptions() throws {
        if #available(iOS 18, tvOS 18, *) {
            throw XCTSkip("Skipped on iOS/tvOS 18 and later.")
        }
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testUpdateWithSetCategoryOptions() throws {
        if #available(iOS 18, tvOS 18, *) {
            throw XCTSkip("Skipped on iOS/tvOS 18 and later.")
        }
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, options: [.duckOthers])
        }.to(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }

    func testNoUpdateWithSetCategoryOptions() throws {
        if #available(iOS 18, tvOS 18, *) {
            throw XCTSkip("Skipped on iOS/tvOS 18 and later.")
        }
        let audioSession = AVAudioSession.sharedInstance()
        expect {
            try audioSession.setCategory(.playback, options: [])
        }.notTo(postNotifications(equal([
            Notification(name: .didUpdateAudioSessionOptions, object: audioSession)
        ])))
    }
}
