//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A `UIImage` that displays an image from an associated source.
///
/// The image is loaded when needed and delivered through usual `PlayerMetadata` updates.
public func LazyUIImage(source: ImageSource) -> UIImage? {
    source.image
}
