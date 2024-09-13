//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFAudio

extension AVAudioSession {
    private static var swizzled = false

    static func enableSetCategoryNotifications() {
        guard !swizzled else { return }
        swizzled = true
        let originalSelector = #selector(AVAudioSession.setCategory(_:mode:options:))
        let swizzledSelector = #selector(AVAudioSession.swizzled_setCategory(_:mode:options:))

        if let originalMethod = class_getInstanceMethod(Self.self, originalSelector),
           let swizzledMethod = class_getInstanceMethod(Self.self, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    @objc
    private func swizzled_setCategory(_ category: Category, mode: Mode, options: CategoryOptions = []) throws {
        try swizzled_setCategory(category, mode: mode, options: options)
        NotificationCenter.default.post(name: .didSetAudioSessionCategory, object: self)
    }
}

extension Notification.Name {
    static let didSetAudioSessionCategory = Notification.Name("AVAudioSessionSetCategoryNotification")
}
