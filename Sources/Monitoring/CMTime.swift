//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

extension CMTime {
    var toMilliseconds: Int? {
        isValid ? seconds.toMilliseconds : nil
    }
}
