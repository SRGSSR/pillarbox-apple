//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum ItemState: Equatable {
    case unknown        // TODO: Maybe rename as .idle
    case readyToPlay
    case ended
}
