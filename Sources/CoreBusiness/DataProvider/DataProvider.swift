//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

protocol DataProvider {
    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL
}
