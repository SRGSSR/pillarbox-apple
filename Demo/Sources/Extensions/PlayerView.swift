//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension PlayerView {
    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> PlayerView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}
