//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum SeekKey: String {
    case time
}

extension Notification.Name {
    static let willSeek = Notification.Name("QueuePlayerWillSeekNotification")
    static let didSeek = Notification.Name("QueuePlayerDidSeekNotification")
}
