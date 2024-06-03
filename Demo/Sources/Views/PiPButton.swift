//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct PiPButton: View {
    var body: some View {
        PictureInPictureButton { isActive in
            Image(systemName: isActive ? "pip.exit" : "pip.enter")
                .tint(.white)
                .font(.system(size: 20))
        }
#if os(iOS)
        .keyboardShortcut("p", modifiers: [])
#endif
    }
}
