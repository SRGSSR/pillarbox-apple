//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct AssetError<M>: Error {
    let error: Error
    let metadata: M
}
