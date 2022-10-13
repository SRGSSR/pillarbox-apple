//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DataError: Error {
    case notFound
}

enum NetworkError: Error {
    case http(statusCode: Int)
}
