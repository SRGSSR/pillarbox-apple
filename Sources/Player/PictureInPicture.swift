//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

public class PictureInPicture: NSObject, ObservableObject {
    private var controller: AVPictureInPictureController?

    override public init() {
        super.init()
    }

    func install(controller: AVPictureInPictureController) {
        self.controller = controller
    }
}
