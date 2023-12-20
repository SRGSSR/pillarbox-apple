//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct PiPButton: View {
    var body: some View {
        PictureInPictureButton { isActive in
            Image(systemName: isActive ? "pip.exit" : "pip.enter")
                .tint(.white)
                .frame(width: 45, height: 45)
        }
    }
}
