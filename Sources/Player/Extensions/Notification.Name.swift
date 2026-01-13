//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum SeekNotificationKey: String {
    case mark
}

// swiftlint:disable:next type_name
enum MediaSelectionCriteriaUpdateNotificationKey: String {
    case mediaSelection
}

extension Notification.Name {
    static let willSeek = Notification.Name("PillarboxPlayer_willSeekNotification")
    static let didSeek = Notification.Name("PillarboxPlayer_didSeekNotification")
    static let didUpdateMediaSelectionCriteria = Notification.Name("PillarboxPlayer_didUpdateMediaSelectionCriteriaNotification")
}
