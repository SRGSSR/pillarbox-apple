//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

public class PictureInPicture: NSObject, ObservableObject {
    private var controllers: [AVPictureInPictureController] = []

    override public init() {
        super.init()
    }

    func append(controller: AVPictureInPictureController) {
        controllers.append(controller)
        print("--> Controller \(Unmanaged.passUnretained(controller).toOpaque()) added, total: \(controllers.count)")
    }
}
