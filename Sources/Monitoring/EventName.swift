//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum EventName: String, Encodable {
    case error = "ERROR"
    case heartbeat = "HEARTBEAT"
    case start = "START"
    case stop = "STOP"
}
