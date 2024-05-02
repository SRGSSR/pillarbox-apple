//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public enum ImageSource: Equatable {
    case none
    case url(URL)
    case request(URLRequest)
    case image(UIImage)
}
