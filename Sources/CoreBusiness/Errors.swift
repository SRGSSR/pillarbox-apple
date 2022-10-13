//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum NetworkError: Error {
    case http(statusCode: Int)
}

enum DataError: Error {
    case notFound
}
