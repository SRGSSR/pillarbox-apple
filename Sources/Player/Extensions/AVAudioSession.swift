//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFAudio

extension AVAudioSession {
    private static var swizzled = false

    static func enableUpdateNotifications() {
        guard !swizzled else { return }
        swizzleSetCategoryModePolicyOptions()
        swizzleSetCategoryModeOptions()
        swizzled = true
    }

    private static func swizzleSetCategoryModePolicyOptions() {
        guard let method = class_getInstanceMethod(Self.self, #selector(setCategory(_:mode:policy:options:))),
              let swizzledMethod = class_getInstanceMethod(Self.self, #selector(swizzled_setCategory(_:mode:policy:options:))) else {
            return
        }
        method_exchangeImplementations(method, swizzledMethod)
    }

    private static func swizzleSetCategoryModeOptions() {
        guard let method = class_getInstanceMethod(Self.self, #selector(setCategory(_:mode:options:))),
              let swizzledMethod = class_getInstanceMethod(Self.self, #selector(swizzled_setCategory(_:mode:options:))) else {
            return
        }
        method_exchangeImplementations(method, swizzledMethod)
    }

    @objc
    private func swizzled_setCategory(_ category: Category, mode: Mode, policy: RouteSharingPolicy, options: CategoryOptions) throws {
        let previousOptions = categoryOptions
        try swizzled_setCategory(category, mode: mode, policy: policy, options: options)
        if categoryOptions != previousOptions {
            NotificationCenter.default.post(name: .didUpdateAudioSessionOptions, object: self)
        }
    }

    @objc
    private func swizzled_setCategory(_ category: Category, mode: Mode, options: CategoryOptions) throws {
        let previousOptions = categoryOptions
        try swizzled_setCategory(category, mode: mode, options: options)
        if categoryOptions != previousOptions {
            NotificationCenter.default.post(name: .didUpdateAudioSessionOptions, object: self)
        }
    }
}

extension Notification.Name {
    static let didUpdateAudioSessionOptions = Notification.Name("PillarboxPlayerDidUpdateAudioSessionOptionsNotification")
}
