//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension CMTime {
    func timeInterval() -> TimeInterval {
        isValid ? seconds : 0
    }
}
