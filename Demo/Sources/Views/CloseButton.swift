//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: dismiss.callAsFunction) {
            Image(systemName: "chevron.down")
                .tint(.white)
                .font(.system(size: 20))
        }
        .shadow(color: .black, radius: 1)
        .keyboardShortcut(.escape, modifiers: [])
    }
}
