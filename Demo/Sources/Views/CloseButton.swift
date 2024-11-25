//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss
    let topBarStyle: Bool

    var body: some View {
        Button(action: dismiss.callAsFunction) {
            Image(systemName: "chevron.down")
                .tint(.white)
                .font(.system(size: 20))
                .topBarStyle(topBarStyle)
        }
        .shadow(color: .black, radius: 1)
        .accessibilityLabel("Close")
#if os(iOS)
        .keyboardShortcut(.escape, modifiers: [])
#endif
        .hoverEffect()
    }

    init(topBarStyle: Bool = false) {
        self.topBarStyle = topBarStyle
    }
}
