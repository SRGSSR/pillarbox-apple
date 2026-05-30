//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URLError {
    static func isCancellationError(_ error: Error) -> Bool {
        error as NSError == URLError(.cancelled) as NSError
    }
}
