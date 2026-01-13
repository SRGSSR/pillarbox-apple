//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public enum Mark: Equatable {
    case time(CMTime)
    case date(Date)

    public func time() -> CMTime? {
        switch self {
        case let .time(time):
            time
        case let .date(date):
            nil // FIXME: UT
        }
    }
}
