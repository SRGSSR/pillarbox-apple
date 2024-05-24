//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVPlayerItemErrorLogEvent {
    /// Info.
    var info: String {
        """
        date ➡️ \(dateFormat(for: date))
        uri ➡️ \(uri ?? "")
        serverAddress ➡️ \(serverAddress ?? "")
        playbackSessionID ➡️ \(playbackSessionID ?? "")
        errorStatusCode ➡️ \(errorStatusCode)
        errorDomain ➡️ \(errorDomain)
        errorComment ➡️ \(errorComment ?? "")
        """
    }

    private func dateFormat(for date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(for: date) ?? "---"
    }
}
