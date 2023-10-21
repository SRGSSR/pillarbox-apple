//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

class PictureInPicture: NSObject {
    let controller: AVPictureInPictureController

    init(controller: AVPictureInPictureController) {
        self.controller = controller
        super.init()
    }
}
